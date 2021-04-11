%3SK3 Computer-Aided Engineering
%Project 2: Demosaicing with Linear Regression

%Minhaj Shah
%400119266


%Matrix Coefficient Generation

%Input Image for Coefficent Matrix Generation 
coeff_img = 'coeff_img.jpeg';
input = double(imread(coeff_img));

fprintf('Part 1: Simulating Mosaic Patches...\n\n')

%Red Channel Columns Padding with Windows
redColumn = im2col(input(:,:,1),[1 1]);
redPad = padarray(input(:,:,1),[2 2],'symmetric','both');
redWindow = im2col(redPad,[5 5]);
%Green Channel Columns and Padding with Windows
greenColumn = im2col(input(:,:,2),[1 1]);
greenPad = padarray(input(:,:,2),[2 2],'symmetric','both');
greenWindow = im2col(greenPad,[5,5]);
%Blue Channel Columns and Padding with Windows
blueColumn = im2col(input(:,:,3),[1 1]);
bluePad = padarray(input(:,:,3),[2 2],'symmetric','both');
blueWindow = im2col(bluePad,[5,5]);

fprintf('Part 2: Solving Linear Least Square Problems...\n\n')

%Red Green Green Blue Pattern
[greenA_rggb,blueA_rggb] = RGGB(redWindow,greenWindow,blueWindow,greenColumn,blueColumn);
%Blue Green Green Red Pattern
[greenA_bggr,redA_bggr] = BGGR(redWindow,greenWindow,blueWindow,greenColumn,redColumn);
%Green Red Blue Green Pattern
[redA_grbg,blueA_grbg] = GRBG(redWindow,greenWindow,blueWindow,redColumn,blueColumn);
%Green Blue Red Green Pattern
[blueA_gbrg,redA_gbrg] = GBRG(redWindow,greenWindow,blueWindow,blueColumn,redColumn);





%Linear Regression

input_img = 'input_img.jpeg';
input = im2double(imread(input_img));


%RGGB Pattern Instantiation
%Dimensions
[x,y,z] = size(input); 
%Red Layer
redPattern = repmat ([1 0;0 0], [x/2,y/2]);
redLayer = input(:,:,1).*redPattern;
%Green Layer
greenPattern = repmat ([0 1;1 0], [x/2,y/2]);
greenLayer = input(:,:,2).*greenPattern;
%Blue Layer
bluePattern = repmat ([0 0;0 1], [x/2,y/2]);
blueLayer = input(:,:,3).*bluePattern;

%Combining RGB Layers to form 1 Channel Image (Black and White)
singleChannel = redLayer(:,:)+greenLayer(:,:)+blueLayer(:,:);
imwrite(singleChannel,"singleChannel.png");

%Image Padding
singleChannelPad = padarray(singleChannel,[3 3],'symmetric');
singleChannelPad(end-2,:) = []; singleChannelPad(:,end-2) = [];
singleChannelPad(3,:) = []; singleChannelPad(:,3) = [];

%R/B Layer Padding for coefficents
redPad = padarray(redLayer,[3 3],'symmetric');
redPad(end-2,:) = []; redPad(:,end-2) = [];
redPad(3,:) = []; redPad(:,3) = [];

%Mosaic Patterns
rggb = [0 1;1 1]; bggr = [1 1;1 0]; grbg = [1 0;1 1]; gbrg = [1 1;0 1];

const = 2;

fprintf('Part 3: Approximating Missing Colours...\n\n')
for r=3 : x+2
    for c=3 : y+2
        
        rowMinusOffset = r-const;
        rowPlusOffset = r+const;
        colMinusOffset = c-const;
        colPlusOffset = c+const;
        
        %Patch Sample
        patch = im2col(singleChannelPad(rowMinusOffset:rowPlusOffset,colMinusOffset:colPlusOffset),[1 1])';
        
        %Equality Test to determine Pattern
        test = redPad(r:rowPlusOffset-1,c:colPlusOffset-1);
        
        %Red Green Green Blue Pattern
        if(isequal(test.*rggb,zeros(2)))
            blueSum = sum(blueA_rggb.*patch);
            blueLayer(rowMinusOffset,colMinusOffset) = blueSum;
            
            greenSum = sum(greenA_rggb.*patch);
            greenLayer(rowMinusOffset,colMinusOffset)= greenSum;
        
        %Blue Green Green Red Pattern
        elseif(isequal(test.*bggr,zeros(2)))
            greenSum = sum(greenA_bggr.*patch);
            greenLayer(rowMinusOffset,colMinusOffset) = greenSum;
            
            redSum = sum(redA_bggr.*patch);
            redLayer(rowMinusOffset,colMinusOffset)= redSum;
        
        %Green Red Blue Green Pattern
        elseif(isequal(test.*grbg,zeros(2)))
            redSum = sum(redA_grbg.*patch);
            redLayer(rowMinusOffset,colMinusOffset) = redSum;
            
            blueSum = sum(blueA_grbg.*patch);
            blueLayer(rowMinusOffset,colMinusOffset)= blueSum;
         
        %Green Blue Red Green Pattern
        elseif(isequal(test.*gbrg,zeros(2)))
            blueSum = sum(blueA_gbrg.*patch);
            blueLayer(rowMinusOffset,colMinusOffset)= blueSum;
            
            redSum = sum(redA_gbrg.*patch);
            redLayer(rowMinusOffset,colMinusOffset)= redSum;
        end
        
    end
end

%Tri Channel RGB Image
%Demosaicing with Linear Regression Finished
linearRegressionDemosaic = cat(3,redLayer,greenLayer,blueLayer);
imwrite(linearRegressionDemosaic,"linearRegressionDemosaic.png");



%MSE Calculations
fprintf('Part 4: MSE...\n')

inputImage = imread(input_img);

%Linear Regression against Ground Truth MSE Calculations 
linearRegressionDemosaic = imread('linearRegressionDemosaic.png');
linearRegressionMSE = immse(linearRegressionDemosaic,inputImage);
fprintf('Linear Regression against Ground Truth MSE is %i\n', linearRegressionMSE)

%Matlab against Ground Truth MSE Calculations 
matlabDemosaic = demosaic(imread('singleChannel.png'),'rggb');
imwrite(matlabDemosaic,"matlabDemosaic.png");
matlabMSE = immse(matlabDemosaic,inputImage);
fprintf('Matlab against Ground Truth MSE is %i\n', matlabMSE)



%Patch Simulation and Coefficent Generation Functions

function [greenA,blueA] = RGGB(redX,greenX,blueX,greenLayer,blueLayer)
%RGGB Pattern
%Simulating Mosaic Patches

offset = 6;
sizing = 3;

%Pattern Distribution
redPattern = repmat ([1 0;0 0], [sizing,sizing]); %R___ Layer
greenPattern = repmat ([0 1;1 0], [sizing,sizing]); %_GG_ Layer
bluePattern = repmat ([0 0;0 1], [sizing,sizing]); %___B Layer

%Apply Offset to Shape Dimensions
redPattern(offset,:) = []; greenPattern(offset,:) = []; bluePattern(offset,:) = [];
redPattern(:,offset) = []; greenPattern(:,offset) = []; bluePattern(:,offset) = [];

%Column Conversion
greenColumn = im2col(greenPattern,[1 1])';
blueColumn = im2col(bluePattern,[1 1])';
redColumn = im2col(redPattern,[1 1])';
X = (redColumn.*redX+greenColumn.*greenX+blueColumn.*blueX)';

%Optimal Coefficent Matrices
blueA = inv(X'*X)*X'*(blueLayer');
greenA = inv(X'*X)*X'*(greenLayer');
end

function [greenA,redA] = BGGR(redX,greenX,blueX,greenLayer,redLayer)
%BGGR Pattern
%Simulating Mosaic Patches

%RGB Patch Patterns
offset = 6;
sizing = 3;

%Pattern Distribution
bluePattern = repmat ([1 0;0 0], [sizing,sizing]); %B___ Layer
greenPattern = repmat ([0 1;1 0], [sizing,sizing]); %_GG_ Layer
redPattern = repmat ([0 0;0 1], [sizing,sizing]); %___R Layer

%Apply Offset to Shape Dimensions
redPattern(offset,:) = []; greenPattern(offset,:) = []; bluePattern(offset,:) = [];
redPattern(:,offset) = []; greenPattern(:,offset) = []; bluePattern(:,offset) = [];

%Column Conversion
blueColumn = im2col(bluePattern,[1,1])';
greenColumn = im2col(greenPattern,[1,1])';
redColumn = im2col(redPattern,[1,1])';
X = (redColumn.*redX+greenColumn.*greenX+blueColumn.*blueX)';

%Optimal Coefficent Matrices
redA = inv(X'*X)*X'*(redLayer');
greenA = inv(X'*X)*X'*(greenLayer');
end

function [redA,blueA] = GRBG(redX,greenX,blueX,redLayer,blueLayer)
%GRBG Pattern
%Simulating Mosaic Patches

%RGB Patch Patterns
offset = 6;
sizing = 3;

%Pattern Distribution
greenPattern = repmat ([1 0;0 1], [sizing,sizing]); %G__G Layer
bluePattern = repmat ([0 0;1 0], [sizing,sizing]); %__B_ Layer
redPattern = repmat ([0 1;0 0], [sizing,sizing]); %_R__ Layer

%Apply Offset to Shape Dimensions
redPattern(offset,:) = []; greenPattern(offset,:) = []; bluePattern(offset,:) = [];
redPattern(:,offset) = []; greenPattern(:,offset) = []; bluePattern(:,offset) = [];

%Column Conversion
greenColumn = im2col(greenPattern,[1,1])';
blueColumn = im2col(bluePattern,[1,1])';
redColumn = im2col(redPattern,[1,1])';
X = (redColumn.*redX+greenColumn.*greenX+blueColumn.*blueX)';

%Optimal Coefficent Matrices
blueA = inv(X'*X)*X'*(blueLayer');
redA = inv(X'*X)*X'*(redLayer');
end

function [blueA,redA] = GBRG(redX,greenX,blueX,blueLayer,redLayer)
%GBRG Pattern
%Simulating Mosaic Patches

%RGB Patch Patterns
offset = 6;
sizing = 3;

%Pattern Distribution
greenPattern = repmat ([1 0;0 1], [sizing,sizing]); %G__G Layer
bluePattern = repmat ([0 1;0 0], [sizing,sizing]); %_B__ Layer
redPattern = repmat ([0 0;1 0], [sizing,sizing]); %__R_ Layer

%Apply Offset to Shape Dimensions
redPattern(offset,:) = []; greenPattern(offset,:) = []; bluePattern(offset,:) = [];
redPattern(:,offset) = []; greenPattern(:,offset) = []; bluePattern(:,offset) = [];

%Column Conversion
greenColumn = im2col(greenPattern,[1 1])';
blueColumn = im2col(bluePattern,[1 1])';
redColumn = im2col(redPattern,[1 1])';
X = (redColumn.*redX+greenColumn.*greenX+blueColumn.*blueX)';

%Optimal Coefficent Matrices
redA = inv(X'*X)*X'*(redLayer');
blueA = inv(X'*X)*X'*(blueLayer');
end
