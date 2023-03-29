function iconImage = recolorIconBackground(iconImage, bgColorNew, bgColorOld)

    if nargin < 3
        bgColorOld = [255,255,255];
    end


    isbackground = @(I, c) I(:,:,1)==c(1) & I(:,:,2)==c(2) & I(:,:,3)==c(3);

    isBackground = isbackground(iconImage, bgColorOld);


    for i = 1:3
        colorChannel = iconImage(:,:,i);
        colorChannel(isBackground) = bgColorNew(i);
        iconImage(:, :, i) = colorChannel;
    end

end