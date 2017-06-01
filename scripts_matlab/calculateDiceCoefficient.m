function dice = calculateDiceCoefficient(segIm, grndTruth)

% Vectorize images
segIm     = segIm(:);
grndTruth = grndTruth(:);

% Calculate Dice Coefficient
dice = 2 * nnz(segIm & grndTruth)/(nnz(segIm) + nnz(grndTruth));
