clc, clearvars % Clear workspace

points1y = {[1,0],[2,2]};
points2y = {[7,6],[9,1]};
pointsyear = {points1y, points2y};

number_years = 2;

for i = 1:number_years
    points = pointsyear{i}; % points for that year
    for l = 1:length(points)
        for k = 1:length(points{l})
            bed = points{l}(1)
            sr = points{l}(2)
        end
        disp('done')
    end
end
