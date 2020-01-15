%% Read original image
imgRGB = imread('Dark3.jpg');
imshow(imgRGB);
%% Scale image orginal image
imgDimension = size(imgRGB(:,:,1));

%Specify image height and width
imgHeight = imgDimension(1);
imgWidth = imgDimension(2);

%If the image is already square
if(imgHeight == imgWidth)
    imgCropped = imgRGB;
end
%Portrait, if image height is larger than image width
if(imgHeight > imgWidth)
    ymin = (imgHeight - imgWidth)/2;
    xmin = 0;
%Landscape image
else
    xmin = (imgWidth - imgHeight)/2;
    ymin = 0;
end
    
side = min(imgDimension); %shortest side of image
imgCropped = imcrop(imgRGB, [round(xmin) round(ymin) side side-1]);% imcrop(Image, [xmin, ymin width height])

%Resize image depending on if it is to small/big
if(side < 20)
    disp('Your images size is to small and have been resized to a 20x20 pixel image. This may effect the image apperence');
    imgResized = imresize(imgCropped, [40 40]);
else
    disp('Your images size is to big and have been resized to a 20x20 pixel image. This may effect the image apperence');
    imgResized = imresize(imgCropped, [40 40]);
end

imshow(imgCropped);
%% L?s in sm? bilderna fr?n databasen
folderPath = '/Users/johannagranstrom/Documents/Skola/Master/Termin8/TNM097/Projekt/Database';
filePattern = dir(fullfile(folderPath, '*.jpg'));

for i = 1:length(filePattern)
    fileName = filePattern(i).name;
    fullName = fullfile(folderPath, fileName);
    fprintf(1, 'Reading images %s\n', fullName);
    imageArray = imread(fullName);
    
    croppedDatabaseImage = imresize(imageArray, [20 20]);
    %Save database as RG
    databaseRGB{i} = croppedDatabaseImage;
    
    %Save database as LAB
    imageArray2Lab = rgb2lab(croppedDatabaseImage);
    databaseLAB{i} = imageArray2Lab;
    
end
dataBase2 = databaseLAB;
%% Skala ned databasen till 100st bilder
databaseLAB = dataBase2;

%threshold = 10 ger 98 bilder i databasen
%threshold = 22 ger 52 bilder i databasen
%threshold = 28 ger 28 bilder i databasen

threshold = 35;
counter = 1;
for n = 1:length(databaseLAB)
    for m = n+1:length(dataBase2)
        nImg = databaseLAB{n};
        
        %Avst?nd f?rg (n) och f?rg (m)
        mImg = dataBase2{m};
        minDist = mean2(sqrt((nImg-mImg).^2));

        %Minsta f?rgskillnader
        if(minDist > threshold)
            newDatabaseLAB{counter} = mImg;
            counter = counter + 1;
            dataBase2(:,m) = [];
        end
        break      
    end
end

%% 
newImage = rgb2lab(imgResized);
%newImage = imresize(imgLAB, 1.25);
%imshow(newImage);

clear indexVidPixel; %Rensa tidigare producerad bild

count = 1;

%G? igenom alla bilder i databasen och j?mf?r mot den pixeln vi ?r p? nu i den stora for-loopen 
for i = 1:size(newImage,1)
    for j = 1:size(newImage,2)
        newImage_L = newImage(i,j,1);
        newImage_A = newImage(i,j,2);
        newImage_B = newImage(i,j,3);
        
         NewDiffernce = 100;%(newImage_L-databasL(1)......)

        for k = 1:length(databaseLAB)
            currentImg = databaseLAB{k};
            databaseL = currentImg(:,:,1);       
            databaseA = currentImg(:,:,2);
            databaseB = currentImg(:,:,3);   

            difference = mean2(sqrt((newImage_L-databaseL).^2+(newImage_A-databaseA).^2 +(newImage_B-databaseB).^2));
            
            if(difference < NewDiffernce) 
                NewDiffernce = difference;
                %k blir det indexet (n?r denna ?r klar) som ger den
                %faktiska bilden f?r just denna pixeln
                indexVidPixel(i,j) = k;
            end
         end
    end
end
%% TEST OPTIMERAD
%tesssst = indexVidPixel(:);

OptimeradDark4 = unique(indexVidPixel);

count = 1;
for a = 1:size(indexVidPixel,1)
    for index = 1:length(databaseLAB)
            
       if(indexVidPixel(a) == index)
           dataBaseDark4{count} = databaseLAB{OptimeradDark4(a)};
           count = count + 1;
       end
            
   end
end

%% FRF
cntr = 1;
for nd = 1:length(dataBaseDark4)
    for md = 1:length(dataBaseDark2)
        nDarkImg = dataBaseDark4{nd};
        
        %Avst?nd f?rg (n) och f?rg (m)
        mDarkImg = dataBaseDark2{md};

        %Minsta f?rgskillnader
        if(nDarkImg == mDarkImg)
            newDatabaseDARKLAB{cntr} = mDarkImg;
            cntr = cntr + 1;
            dataBaseDark2(:,md) = [];
        end
        break      
    end
end


%% Aterskapadbild = indexVidPixel(i,j)
%theFinalImage = zeros(size(newImage,1),size(newImage,2),3);
sizeOfImages = size(databaseLAB{1},1);
RangeX = 1:(size(croppedDatabaseImage,1)):(size(indexVidPixel,1)*sizeOfImages+1);     %S?tter upp storleken p? slutbilden
RangeY = 1:(size(croppedDatabaseImage,2)):(size(indexVidPixel,2)*sizeOfImages+1);     %D? varje bild motsvarar 128x128 pixlar

%% Loop for recreating original image with small images
for a = 1:size(indexVidPixel,1)
    for b = 1:size(indexVidPixel,2)
        for index = 1:length(databaseLAB)
            
            if(indexVidPixel(a,b) == index)
                theFinalImage(RangeX(a):RangeX(a+1)-1,RangeY(b):RangeY(b+1)-1,:) = databaseLAB{indexVidPixel(a,b)};
            end
            
        end
    end
end

imshow(theFinalImage);

figure;
test = lab2rgb(theFinalImage);
imshow(test);


%% Kvalitetsm?tt
%M?ste rezise s? den reproducerade bilden ?r lika stor som originalsolrosbilden f?r annars fungerar inte SSIM
doubleCropped = imresize(imgCropped, [800 800]);
doubleCropped1 = im2double(doubleCropped);

%Ska vara ett h?gt v?rde(?)
%snr_distort1 = snr(doubleCropped, resizeTest);

%SSIM ska vara s? n?ra ett som m?jligt
%window = ones(20, 20, 3);
%K = [0.01 0.03];
ssim_distort1 = ssim(doubleCropped1, test, K,window);


%%
imshow(resizeTest);




