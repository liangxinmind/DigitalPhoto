% 定位正方形

image_init = imread('./IMG-2/04.tif');
n = ndims(image_init);
if n > 2
    image = rgb2grad(image_init);
else
    image = image_init;
end

subplot(1, 2, 1)
imshow(image_init),title("原图像");
subplot(1, 2, 2)
imshow(image),title("原图像");

a_size = size(image);
b = ones(a_size);

for i = 1:a_size(1)
    for j = 1:a_size(2)
        if image(i,j) >= 0 && image(i,j) <= 50
            b(i,j) = 0;
        end
    end
end
B = [1 1 1 1;1 1 1 1;1 1 1 1;1 1 1 1];  %此模板的选择有待再考虑
b = imerode(b,B);

for i = 1:a_size(1)
    for j = 1:a_size(2)
        if  b(i,j) == 0
            image(i,j) = 255;
        end
    end
end

bw = edge(image, 'prewitt');     %边缘检测   边缘检测结束后发现还是有一些鼓励的小点，不多它们没有形成闭合的曲线
[L,num] = bwlabel(bw);               %这里已经给每个区域标好号了，使用bwlabel的话会把鼓励的不成闭合曲线的点也算进去
%一些独立点的像素数量是比较少的，所以可以通过检测每一块区域的像素点大小来决定是不是要删除此像素块
for i = 1:num
        [r, c] = find(L == i);
        size_L = size([r, c]);
        if size_L(1, 1) < 30
            L(r, c) = 0;
        end
end
L = logical(L);

se = strel('disk',4);   %创造一个平坦的圆盘型结构元素，其半径为2
L = imclose(L, se);    %关闭图像
[L,num1] = bwlabel(L);
L = rot90(L, 3);
L = fliplr(L);
pixel = cell([num1,1]);
centre = zeros(num1,2);
size_L = size(L);
for i = 1:num1
    [r,c]=find(L==i);
    pixel{i} = [r,c]; 
    hold on
    mean_pixel = mean(pixel{i});
    centre(i,:) = mean_pixel;         
    plot(mean_pixel(1,1), mean_pixel(1,2),'')
    size_r = size(r);
    distance = zeros(size_r);
    for j = 1:1:size_r(1)
        distance(j) = sqrt((r(j)-mean_pixel(1))^2 + (c(j)-mean_pixel(2))^2);
    end
    p = polyfit((1:size_r(1))', distance,7);
    x = (1:size_r(1))';
    y = p(1)*x.^7 + p(2)*x.^6 + p(3)*x.^5 + p(4)*x.^4 + p(5)*x.^3 + p(6)*x.^2 + p(7)*x.^1 + p(8);
    %plot(x,y)            %对数据进行拟合，因为数据过于杂乱，不好判断    
    min_distance = min(distance);
    max_distance = max(distance);
    min_y        =  min(y);
    max_y        =  max(y);
    num_peaks    =  size(findpeaks(-y));
    if (max_distance - min_distance) <= 15 && (max_y - min_y) <= 15
       % text(mean_pixel(1,1),mean_pixel(1,2),sprintf('圆形  %d',i))
    elseif num_peaks(1) == 2
       % text(mean_pixel(1,1),mean_pixel(1,2),sprintf('三角形  %d',i))    
    else
        text(mean_pixel(1,1),mean_pixel(1,2), sprintf('正方形  %d',i))
    end    
end
