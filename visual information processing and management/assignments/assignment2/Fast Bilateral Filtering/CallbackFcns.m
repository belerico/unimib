function CallbackFcns (action)
switch (action)
    case 'sigmas_slider'
        sigmas = get(gcbo, 'Value');
        sigmas = round(sigmas) + 1;
        updatesigmas(sigmas);
    case 'sigmar_slider'
        sigmar = get(gcbo, 'Value');
        sigmar = (round(sigmar*10))/10 + 5;
        updatesigmar(sigmar);
    case 'sigmas_edit'
        sigmas = eval(get(gcbo, 'String'));
        updatesigmas(sigmas);
    case 'sigmar_edit'
        sigmar = eval(get(gcbo, 'String'));
        updatesigmar(sigmar);
    case 'browse'
        [filename, user_canceled] = imgetfile;
        if (~user_canceled)
            imagepath_Handle = findobj(gcbf,'Tag','imagepath');
            set(imagepath_Handle,'String',filename);
        end
    case 'load'
        imagepath_Handle = findobj(gcbf,'Tag','imagepath');
        mread = imread(get(imagepath_Handle,'String'));
        axes(findobj(gcbf,'Tag','input'));
        cla; hold on;
        imshow(mread); axis('image', 'off');
        minput = double(mread);
        set(gcbf,'UserData',minput);
    case 'filter'
        minput = get(gcbf,'UserData');
        editS_Handle = findobj(gcbf,'Tag','editS');
        sigmas = eval(get(editS_Handle,'String'));
        editR_Handle = findobj(gcbf,'Tag','editR');
        sigmar = eval(get(editR_Handle,'String'));
        [moutput,params] = shiftableBF(minput,sigmas,sigmar);
        axes(findobj(gcbf,'Tag','output'));
        cla; hold on;
        imshow(uint8(moutput)); axis('image', 'off');
        
        T = params.T;
        t = - T : 0.01 : T;
        gexact = exp(-0.5*t.^2/sigmar^2);
        g = zeros(1,length(t));
       T0 = max(T,ceil(3*sigmar));
        w0 = pi/T0;
        for n = 1:length(params.coeff)
            g = g + params.coeff(n)*cos((n-1)*w0*t);
        end
        rkernel_Handle = findobj(gcbf,'Tag','rkernelplot');
        axes(rkernel_Handle);
        cla;
        set(rkernel_Handle,'Color','White');
        set(rkernel_Handle,'AmbientLightColor','White');
        set(rkernel_Handle,'XColor','Black');
        set(rkernel_Handle,'YColor','Black');
        hold on;
        box on;
        plot(t,gexact, 'r','LineWidth',3); hold on, plot(t,g,'k','LineWidth',2);
        hleg=legend('Target Gaussian','Fourier Approximation');
        set(hleg,'fontsize',8);
        axis tight; grid on;
    case 'save'
        imsave(findobj(gcbf,'Tag','output'));
end

function updatesigmas (sigmas)
sliderS_Handle = findobj(gcbf,'Tag','sliderS');
set(sliderS_Handle,'Value',sigmas-1);
editS_Handle = findobj(gcbf,'Tag','editS');
set(editS_Handle,'String',sigmas);

function updatesigmar (sigmar)
sliderR_Handle = findobj(gcbf,'Tag','sliderR');
set(sliderR_Handle,'Value',sigmar-5);
editR_Handle = findobj(gcbf,'Tag','editR');
set(editR_Handle,'String',sigmar);