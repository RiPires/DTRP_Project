[img, map] = imread("AddFileIcon.png");
%imshow(img, map)
img_rgb = ind2rgb(img, map);
imshow(img_rgb)