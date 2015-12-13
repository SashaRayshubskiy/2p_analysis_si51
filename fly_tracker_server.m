function [] = fly_tracker_server()
% fly_tracker_server Summary of this function goes here

% example for using the ScanImage API to set up a grab
hSI = evalin('base','hSI');             % get hSI from the base workspace

%%%%
% Start a server to listen on the socket to fly tracker
%%%%
clear t;
PORT = 30000;
t = tcpip('0.0.0.0', PORT, 'NetworkRole', 'server');
set(t, 'InputBufferSize', 30000); 
set(t, 'TransferDelay', 'off');
disp(['About to listen on port: ' num2str(PORT)]);
fopen(t);
pause(1.0);

while 1
    
    % Read the message     
    while (t.BytesAvailable == 0)
        pause(0.1);
    end
        
    data = fscanf(t, '%s', t.BytesAvailable);
    disp(data);
    
    if( strcmp(data,'END_OF_SESSION') == 1 )
        break;
    end
        
    hSI.hScan2D.logFileStem = data;      % set the base file name for the Tiff file    
    hSI.hChannels.loggingEnable = true;     % enable logging    
    hSI.startGrab();                        % start the grab
end

% close the socket
fclose(t);
delete(t);

end