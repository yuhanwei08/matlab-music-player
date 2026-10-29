classdef MP3English < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        human         matlab.ui.control.StateButton
        resound       matlab.ui.control.DropDown
        Label_11      matlab.ui.control.Label
        TabGroup      matlab.ui.container.TabGroup
        Tab           matlab.ui.container.Tab
        UIAxes1       matlab.ui.control.UIAxes
        UIAxes2       matlab.ui.control.UIAxes
        Tab_2         matlab.ui.container.Tab
        UIAxes3       matlab.ui.control.UIAxes
        Tab_3         matlab.ui.container.Tab
        UIAxes5       matlab.ui.control.UIAxes
        UIAxes4       matlab.ui.control.UIAxes
        music_volume  matlab.ui.control.Slider
        Label_9       matlab.ui.control.Label
        total_time    matlab.ui.control.Label
        Label_7       matlab.ui.control.Label
        current_time  matlab.ui.control.Label
        stop_music    matlab.ui.control.StateButton
        next          matlab.ui.control.StateButton
        last          matlab.ui.control.StateButton
        play_music    matlab.ui.control.Button
        play_speed    matlab.ui.control.DropDown
        Label_4       matlab.ui.control.Label
        process       matlab.ui.control.Slider
        Label_2       matlab.ui.control.Label
        Label         matlab.ui.control.Label
        Panel         matlab.ui.container.Panel
        MusicList     matlab.ui.control.ListBox
        del           matlab.ui.control.Button
        add           matlab.ui.control.Button
        Image         matlab.ui.control.Image
    end


    properties (Access = private)
        fs;
        speed = 1;
        sample;
        pathlist = {};
        N = 0;
        audiodata;
        total;
        current;
        player;
        my_timer;
    end
    
    methods (Access = private)

        function set_total_time(app)
            if isempty(app.player) == 0
                total_minutes = floor((app.player.TotalSamples/app.player.SampleRate)/60);
                total_seconds = floor(app.player.TotalSamples/app.player.SampleRate - total_minutes*60);
                min = timeformat(app,total_minutes);
                sec = timeformat(app,total_seconds);
                app.total_time.Text = [min,':',sec];
            end
        end
        
    
        
        function update_process1(app,hObject,eventdata)
            if ~isempty(app.player)
                if strcmpi(get(app.player,'running'),'on')
                    set_total_time(app);
                    app.sample = app.player.SampleRate/app.speed;
                    current_minutes = floor((app.player.CurrentSample/app.sample)/60);
                    current_seconds = floor(app.player.CurrentSample/app.sample - current_minutes*60);
                    min = timeformat(app,current_minutes);
                    sec = timeformat(app,current_seconds);
                    app.current_time.Text = [min,':',sec];
                    Fs = app.player.SampleRate;
                    n = 0:1:app.player.TotalSamples-1;
                    if app.player.TotalSamples < Fs*40
                        if app.player.CurrentSample+Fs*1<= app.player.TotalSamples
                            n1 = app.player.CurrentSample:1:app.player.CurrentSample+Fs*1;
                        else
                            n1 = app.player.CurrentSample:1:app.player.TotalSamples;
                        end
                    else
                        if app.player.CurrentSample+Fs*10<= app.player.TotalSamples
                            n1 = app.player.CurrentSample:1:app.player.CurrentSample+Fs*10;
                        else
                            n1 = app.player.CurrentSample:1:app.player.TotalSamples;
                        end
                    end
                    y = app.audiodata(:,1);
                    y1 = app.audiodata(n1,1);
                    plot(app.UIAxes1,n/Fs,y,'-k',n1/Fs,y1,'-r');
                    plot(app.UIAxes4,n/Fs,y,'-k');
                    plot(app.UIAxes2,n1/Fs,y1,'-r');

                    Y = fft(y);Y = abs(Y);
                    L = floor(app.player.TotalSamples/2)+1;
                    Yh = Y(1:L);
                    h = Yh/Fs;
                    fz = Fs/app.player.TotalSamples;
                    k = 0:L-1;
                    f = fz*k;
                    plot(app.UIAxes3,f,h);

                    if app.player.TotalSamples/app.player.SampleRate <= 30
                       Fs = floor(Fs/100);
                    else
                       Fs = floor(Fs);
                    end
                    yleft = y(:,1);
                    N1 = floor(length(yleft)/Fs);
                    yleft = yleft(1:N1*Fs);
                    N0 = length(yleft);
                    y1 = reshape(yleft,Fs,[]);
                    y1 = max(y1);
                    x1 = linspace(0,N0-1,length(y1));
                    x2 = 0:1:N0-1;
                    y2 = interp1(x1,y1,x2,'spline');
                    plot(app.UIAxes5,x2,y2,'-k');


                    app.process.Value = app.player.CurrentSample/app.player.TotalSamples;
                    if app.player.CurrentSample == 1
                        stop(app.player);
                        app.play_music.Text = '▶';
                        app.speed = 1;
                        app.play_speed.Value = 'x1';
                    end
                      
                else
                    if isempty(app.MusicList.Items)
                        app.total_time.Text = ['00',':','00'];
                        app.current_time.Text = ['00',':','00'];
                        app.process.Value = 0;
                        app.play_music.Text = '▶';
                    end
                end
                
            end

            if isempty(app.player)&&~isempty(app.MusicList.Value)
                app.current_time.Text = ['00',':','00'];
                app.process.Value = 0;
                app.play_music.Text = '▶'; 
            end
            if isempty(app.player)&&isempty(app.MusicList.Value)
                app.total_time.Text = ['00',':','00'];
                app.current_time.Text = ['00',':','00'];
                app.process.Value = 0;
                app.play_music.Text = '▶';
            end
        end
        
        
        function str = timeformat(app,num)
            if num < 10
                str = ['0',num2str(num)];
            else
                str = num2str(num);
            end
        end
        

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.my_timer = timer("ExecutionMode","fixedSpacing","Period",0.1,"TimerFcn",@app.update_process1);
            start(app.my_timer);
        end

        % Button pushed function: add
        function addPushed(app, event)

            if ~isempty(app.player)
                pause(app.player);
                app.play_music.Text = '▶';
            end
           
            [filename,app.pathlist{app.N+1}] = uigetfile({'*.mp3;*.mp4;*.wav','Audio files'},'multiselect','off');
           
            if filename ~= 0    
                dims = size(app.MusicList.Items);
                n = dims(2);
                if ismember(filename,app.MusicList.Items)
                    errordlg('A track with this filename has already been imported.');
                else
                    app.MusicList.Items{n+1} = filename;
                    app.N = app.N + 1;
                end
            end
        end

        % Button pushed function: del
        function delButtonPushed(app, event)
            
            if ~isempty(app.player)
                pause(app.player);
                app.play_music.Text = '▶';
            end
            if isempty(app.MusicList.Items)
                errordlg('There are no tracks to remove.');
            else 
                if isempty(app.MusicList.Value) == 0
                    n = 1;
                    while isequal(app.MusicList.Items{n},app.MusicList.Value) == 0
                        n = n + 1;
                    end
                    app.MusicList.Items(n) = [];
                    app.pathlist(n) = [];
                    app.N = app.N - 1;
                else
                    errordlg('Select a track to remove.');
                end          
            end   
        end

        % Value changed function: last
        function lastValueChanged(app, event)
            n = 1;
            while isequal(app.MusicList.Items{n},app.MusicList.Value) == 0
                n = n + 1;
            end
            if (n-1) >= 1
                if ~isempty(app.player)
                    stop(app.player);
                    app.play_music.Text = '▶';
                    app.process.Value = 0;
                    app.total_time.Text = ['00',':','00'];
                    app.current_time.Text = ['00',':','00'];
                end
                app.MusicList.Value = app.MusicList.Items{n-1};
                MusicListValueChanged(app, event);
                app.last.Value = false;
                play_musicButtonPushed(app, event);
            else
                app.last.Value = false;
                errordlg('No further track is available in this direction.');
            end
        end

        % Button pushed function: play_music
        function play_musicButtonPushed(app, event)
            app.play_music.BackgroundColor = [0.8, 0.2, 0.2];

            if isempty(app.MusicList.Value) == 0
                if isempty(app.player) == 1
                    n = 1
                    while isequal(app.MusicList.Items{n},app.MusicList.Value) == 0
                        n = n + 1;
                    end
                    fullpath = [app.pathlist{n},app.MusicList.Value];
                    [app.audiodata,app.fs] = audioread(fullpath);
                    app.player = audioplayer(app.audiodata,app.fs);
                    set_total_time(app);
                end

                if app.play_music.Text == '▶'

                    if app.player.CurrentSample == 1
                        play(app.player);
                    elseif app.player.CurrentSample ~= 1
                        resume(app.player);
                    end
                    app.play_music.Text = '| |';
                else
                    pause(app.player);
                    app.play_music.Text = '▶';
                end

            else
                errordlg('Select a track before starting playback.');
            end          
        end

        % Value changed function: play_speed
        function play_speedValueChanged(app, event)
            value = app.play_speed.Value;
            if isempty(app.player) ~= 1
                app.player.SampleRate = (app.player.SampleRate)/(app.speed);
                app.speed = str2num(strip(value,'left','x'));
                app.player.SampleRate = (app.player.SampleRate)*(app.speed);
            else
                errordlg('No audio is currently loaded for playback.');
            end
        end

        % Value changed function: stop_music
        function stop_musicValueChanged(app, event)

            if isempty(app.player) ~= 1
                stop(app.player);
                app.play_music.Text = '▶';
                app.stop_music.Value = false;
                app.process.Value = 0;
                app.current_time.Text = '00:00';
            end
        end

        % Value changed function: MusicList
        function MusicListValueChanged(app, event)

            if ~isempty(app.player)
                stop(app.player);
                clear app.player;
                n = 1;
                while ~isequal(app.MusicList.Items{n},app.MusicList.Value)
                    n = n + 1;
                end
                fullpath = [app.pathlist{n},app.MusicList.Value];
                [app.audiodata,app.fs] = audioread(fullpath);
                app.player = audioplayer(app.audiodata,app.fs);
                set_total_time(app);
                @update_process1;  
            end
        end

        % Value changed function: next
        function nextValueChanged(app, event)
            n = 1;
            while ~isequal(app.MusicList.Items{n},app.MusicList.Value)
                n = n + 1;
            end
            if (n+1) <= app.N
                if ~isempty(app.player)
                    stop(app.player);
                    app.play_music.Text = '▶';
                    app.process.Value = 0;
                    app.total_time.Text = ['00',':','00'];
                    app.current_time.Text = ['00',':','00'];
                end
                app.MusicList.Value = app.MusicList.Items{n+1};
                MusicListValueChanged(app, event);
                app.next.Value = false;
                play_musicButtonPushed(app, event);
            else
                app.next.Value = false;
                errordlg('No further track is available in this direction.');
            end
            
        end

        % Value changed function: music_volume
        function music_volumeValueChanged(app, event)

            if ~isempty(app.player)
                changedValue = event.Value;
                currentSample = get(app.player,'currentSample');
                yC=app.audiodata*changedValue/30;
                app.player=audioplayer(yC,app.fs);
                play(app.player,currentSample);
            else
                errordlg('No audio is currently loaded for playback.');
            end
        end

        % Value changing function: music_volume
        function music_volumeValueChanging(app, event)
            if isempty(app.player) == 0
                pause(app.player);
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            stop(app.my_timer);
            delete(app);
        end

        % Value changed function: process
        function processValueChanged(app, event)

            value = app.process.Value;
            if ~isempty(app.player)
                pause(app.player);
                C = get(app.player,'TotalSamples');
                play(app.player,round(value*C));
                app.play_music.Text = '| |';
            else
                app.process.Value = 0;
                errordlg('No audio is currently loaded for playback.'); 
            end
        end

        % Value changed function: resound
        function resoundValueChanged(app, event)
            if ~isempty(app.player)
                pause(app.player);
                Current = app.player.currentSample;
                app.play_music.Text = '▶';
                value = app.resound.Value;
                
                n = 1;
                while ~isequal(app.MusicList.Items{n},app.MusicList.Value)
                    n = n + 1;
                end
                fullpath = [app.pathlist{n},app.MusicList.Value];
                [app.audiodata,app.fs] = audioread(fullpath);
                app.player = audioplayer(app.audiodata,app.fs);
              
                num=str2double(value);
                I=app.audiodata;
                z=[zeros(num,2);I];
                y=[I;zeros(num,2)];
                app.audiodata=y+z;
                app.player = audioplayer(app.audiodata,app.fs);
                play(app.player,Current);
                app.play_music.Text = '| |';
            else
                errordlg("No audio is currently loaded for playback.");
                app.resound.Value = "0";
            end            
        end

        % Value changed function: human
        function humanValueChanged(app, event)
            value = app.human.Value;
            if value == true
                if ~isempty(app.player)
                    pause(app.player);
                    Current = app.player.currentSample;
                    app.play_music.Text = '▶';
                    SoundLeft=app.audiodata(:,1);
                    SoundRight=app.audiodata(:,2);
                     
                    NewLeft=SoundLeft-SoundRight;
                    NewRight=SoundLeft-SoundRight;
                    
                    Sound(:,1)=NewLeft;
                    Sound(:,2)=NewRight;
                    
                    BP=fir1(300,[500,2000]/(app.fs/2));
                    CutDown=filter(BP,1,Sound);
                    Sound_Final=Sound-0.6*abs(CutDown);
                    
                    app.player = audioplayer(Sound_Final,app.fs);
                    play(app.player,Current);
                    app.play_music.Text = '| |';
                else
                    errordlg("No track is currently loaded for playback.");
                end
            end
            if value == false
                if ~isempty(app.player)
                    pause(app.player);
                    app.play_music.Text = '▶';
                    Current = app.player.currentSample;
                    n = 1;
                    while ~isequal(app.MusicList.Items{n},app.MusicList.Value)
                        n = n + 1;
                    end
                    fullpath = [app.pathlist{n},app.MusicList.Value];
                    [app.audiodata,app.fs] = audioread(fullpath);
                    app.player = audioplayer(app.audiodata,app.fs);
                    play(app.player,Current);
                    app.play_music.Text = '| |';
                else
                    errordlg("No track is currently loaded for playback.");
                end
            end
        end

        % Callback function
        function styleValueChanged(app, event)

            value = app.style.Value;
            pause(app.player);
            app.play_music.Text = '▶';
            Current = app.player.currentSample;
            n = 1;
            while ~isequal(app.MusicList.Items{n},app.MusicList.Value)
                  n = n + 1;
            end
            fullpath = [app.pathlist{n},app.MusicList.Value];
            [app.audiodata,app.fs] = audioread(fullpath);
            f = [0 0.0016 0.0028 0.0057 0.0113 0.0227 0.0454 0.0907 0.1814 0.3628 0.7256 1];
            m = zeros(1,12);
            switch value
                case 'normal'
                    
                case 'Jazz_t_domain'
                    [M,Wn]=buttord(2*pi*200,2*pi*100,1,15,'s');
                    [Z,P,K]=buttap(M);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2hp(Bap,Aap,Wn);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*2000,2*pi*3000,1,5,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,6000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*3000,2*pi*4000,1,4,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,6000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*4000,2*pi*5000,1,3,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,6000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*1500,2*pi*2500,1,5,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,6000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata = filter(bz,az,app.audiodata);
                case 'Rock_t_domain'
                    [M,Wn]=cheb1ord(2*pi*125,2*pi*700,1,15,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*500,2*pi*1000,1,12,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1500);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*1000,2*pi*1500,1,3,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                case 'Dance_t_domain'
                    [M,Wn]=cheb1ord(2*pi*100,2*pi*400,0.0001,0.00010001,'s');
                    [Z,P,K]=cheb1ap(M,0.0001);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bp(Bap,Aap,Wn,400);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*40,2*pi*80,0.0001,0.000100002,'s');
                    [Z,P,K]=cheb1ap(M,0.0001);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bp(Bap,Aap,Wn,400);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*20,2*pi*60,0.0001,0.000100001,'s');
                    [Z,P,K]=cheb1ap(M,0.0001);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bp(Bap,Aap,Wn,400);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*250,2*pi*700,1,5,'s');
                    [Z,P,K]=cheb1ap(M,1);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*500,2*pi*1000,2,5,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1000);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*700,2*pi*1200,2,15,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1200);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*1000,2*pi*1500,2,19,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1200);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*1200,2*pi*1700,2,19,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1200);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*1600,2*pi*2100,2,19,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1200);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*2000,2*pi*2500,2,19,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1200);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                    [M,Wn]=cheb1ord(2*pi*2200,2*pi*2700,2,19,'s');
                    [Z,P,K]=cheb1ap(M,2);
                    [Bap,Aap]=zp2tf(Z,P,K);
                    [b,a]=lp2bs(Bap,Aap,Wn,1200);
                    [bz,az]=bilinear(b,a,app.fs);
                    app.audiodata=filter(bz,az,app.audiodata);
                case "Jazz_f_domain"
                    m = [0 1.995 1.995 1.259 1.585 0.631 0.794 1 1.259 1.585 2.512 0];
                    b = fir2(100,f,m);
                    app.audiodata = filter(b,1,app.audiodata);
                case "Rock_f_domain"
                    m = [0 2.512 1.995 1.995 1.259 1 0.794 1 1.259 1.585 2.512 0];
                    b = fir2(100,f,m);
                    app.audiodata = filter(b,1,app.audiodata);
                case "Metal_f_domain"
                    m = [0 0.501 3.162 2.512 0.631 0.501 0.631 1.585 1.995 1.259 2.512 0];
                    b = fir2(100,f,m);
                    app.audiodata = filter(b,1,app.audiodata);
                case "Bass_f_domain"
                    m = [0 3.981 3.162 6.310 1.585 1 1 1 1 1 1 0];
                    b = fir2(100,f,m);
                    app.audiodata = filter(b,1,app.audiodata);
            end
            app.player = audioplayer(app.audiodata,app.fs);
            play(app.player,Current);
            app.play_music.Text = '| |';
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            colormap(app.UIFigure, 'cool');
            app.UIFigure.Position = [100 100 746 508];
            app.UIFigure.Name = 'Music Player';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Enable = 'off';
            app.Image.Position = [-265 1 1278 508];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'OIP-C (5).jpg');

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.TitlePosition = 'centertop';
            app.Panel.Title = 'Playlist';
            app.Panel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Panel.FontName = 'Arial';
            app.Panel.FontWeight = 'bold';
            app.Panel.FontSize = 16;
            app.Panel.Position = [22 200 188 256];

            % Create add
            app.add = uibutton(app.Panel, 'push');
            app.add.ButtonPushedFcn = createCallbackFcn(app, @addPushed, true);
            app.add.Icon = fullfile(pathToMLAPP, 'dr.jpg');
            app.add.FontName = 'Arial';
            app.add.FontSize = 14;
            app.add.Position = [12 12 73 27];
            app.add.Text = 'Import';

            % Create del
            app.del = uibutton(app.Panel, 'push');
            app.del.ButtonPushedFcn = createCallbackFcn(app, @delButtonPushed, true);
            app.del.Icon = fullfile(pathToMLAPP, 'sc.jpg');
            app.del.FontName = 'Arial';
            app.del.FontSize = 14;
            app.del.Position = [103 12 73 27];
            app.del.Text = 'Remove';

            % Create MusicList
            app.MusicList = uilistbox(app.Panel);
            app.MusicList.Items = {};
            app.MusicList.ValueChangedFcn = createCallbackFcn(app, @MusicListValueChanged, true);
            app.MusicList.FontSize = 14;
            app.MusicList.Position = [12 52 164 171];
            app.MusicList.Value = {};

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.VerticalAlignment = 'top';
            app.Label.FontName = 'Arial';
            app.Label.FontSize = 18;
            app.Label.FontWeight = 'bold';
            app.Label.Position = [0 471 746 23];
            app.Label.HorizontalAlignment = 'center';
            app.Label.Text = 'Music Player';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.VerticalAlignment = 'top';
            app.Label_2.FontName = 'Arial';
            app.Label_2.FontSize = 14;
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Position = [225 68 63 22];
            app.Label_2.Text = 'Progress';

            % Create process
            app.process = uislider(app.UIFigure);
            app.process.Limits = [0 1];
            app.process.MajorTicks = [];
            app.process.MajorTickLabels = {};
            app.process.ValueChangedFcn = createCallbackFcn(app, @processValueChanged, true);
            app.process.MinorTicks = [];
            app.process.FontName = 'Arial';
            app.process.Position = [301 81 323 3];

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.VerticalAlignment = 'top';
            app.Label_4.FontName = 'Arial';
            app.Label_4.FontSize = 16;
            app.Label_4.FontWeight = 'bold';
            app.Label_4.Position = [18 139 69 22];
            app.Label_4.Text = 'Speed';

            % Create play_speed
            app.play_speed = uidropdown(app.UIFigure);
            app.play_speed.Items = {'x0.5', 'x0.75', 'x1', 'x1.25', 'x1.5', 'x2'};
            app.play_speed.ValueChangedFcn = createCallbackFcn(app, @play_speedValueChanged, true);
            app.play_speed.FontWeight = 'bold';
            app.play_speed.Position = [94 138 116 28];
            app.play_speed.Value = 'x1';

            % Create play_music
            app.play_music = uibutton(app.UIFigure, 'push');
            app.play_music.ButtonPushedFcn = createCallbackFcn(app, @play_musicButtonPushed, true);
            app.play_music.BackgroundColor = [0.9686 0.6706 0.9686];
            app.play_music.FontSize = 26;
            app.play_music.FontWeight = 'bold';
            app.play_music.Position = [442 12 74 56];
            app.play_music.Text = '▶';

            % Create last
            app.last = uibutton(app.UIFigure, 'state');
            app.last.ValueChangedFcn = createCallbackFcn(app, @lastValueChanged, true);
            app.last.Text = 'Previous';
            app.last.BackgroundColor = [0.5412 0.8902 1];
            app.last.FontName = 'Arial';
            app.last.FontSize = 14;
            app.last.FontWeight = 'bold';
            app.last.Position = [340 24 90 32];

            % Create next
            app.next = uibutton(app.UIFigure, 'state');
            app.next.ValueChangedFcn = createCallbackFcn(app, @nextValueChanged, true);
            app.next.Text = 'Next';
            app.next.BackgroundColor = [0.5412 0.8902 1];
            app.next.FontName = 'Arial';
            app.next.FontSize = 14;
            app.next.FontWeight = 'bold';
            app.next.Position = [528 24 90 32];

            % Create stop_music
            app.stop_music = uibutton(app.UIFigure, 'state');
            app.stop_music.ValueChangedFcn = createCallbackFcn(app, @stop_musicValueChanged, true);
            app.stop_music.Text = 'Stop';
            app.stop_music.BackgroundColor = [0.9686 0.6706 0.9686];
            app.stop_music.FontName = 'Arial';
            app.stop_music.FontSize = 14;
            app.stop_music.FontWeight = 'bold';
            app.stop_music.Position = [630 24 110 32];

            % Create current_time
            app.current_time = uilabel(app.UIFigure);
            app.current_time.FontSize = 14;
            app.current_time.FontWeight = 'bold';
            app.current_time.Position = [642 70 41 22];
            app.current_time.Text = '00:00';

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.FontSize = 14;
            app.Label_7.FontWeight = 'bold';
            app.Label_7.Position = [685 70 10 22];
            app.Label_7.Text = '/';

            % Create total_time
            app.total_time = uilabel(app.UIFigure);
            app.total_time.FontSize = 14;
            app.total_time.FontWeight = 'bold';
            app.total_time.Position = [697 70 41 22];
            app.total_time.Text = '00:00';

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.HorizontalAlignment = 'right';
            app.Label_9.VerticalAlignment = 'top';
            app.Label_9.FontName = 'Arial';
            app.Label_9.FontSize = 16;
            app.Label_9.FontWeight = 'bold';
            app.Label_9.Position = [18 29 69 22];
            app.Label_9.Text = 'Volume';

            % Create music_volume
            app.music_volume = uislider(app.UIFigure);
            app.music_volume.MajorTicks = [];
            app.music_volume.MajorTickLabels = {};
            app.music_volume.ValueChangedFcn = createCallbackFcn(app, @music_volumeValueChanged, true);
            app.music_volume.ValueChangingFcn = createCallbackFcn(app, @music_volumeValueChanging, true);
            app.music_volume.MinorTicks = [];
            app.music_volume.FontName = 'Arial';
            app.music_volume.Position = [98 42 107 3];
            app.music_volume.Value = 30;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [227 108 505 348];

            % Create Tab
            app.Tab = uitab(app.TabGroup);
            app.Tab.Title = 'Waveform';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.Tab);
            xlabel(app.UIAxes2, 't/s')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.PlotBoxAspectRatio = [4.3953488372093 1 1];
            app.UIAxes2.FontName = 'Arial';
            app.UIAxes2.FontWeight = 'bold';
            app.UIAxes2.XLim = [-Inf Inf];
            app.UIAxes2.YLim = [-Inf Inf];
            app.UIAxes2.XTickLabelRotation = 0;
            app.UIAxes2.YTickLabelRotation = 0;
            app.UIAxes2.YTickLabel = {'0'; '0.5'; '1'};
            app.UIAxes2.ZTickLabelRotation = 0;
            app.UIAxes2.Box = 'on';
            app.UIAxes2.XGrid = 'on';
            app.UIAxes2.YGrid = 'on';
            app.UIAxes2.TitleFontWeight = 'bold';
            colormap(app.UIAxes2, 'cool')
            app.UIAxes2.Position = [2 8 501 155];

            % Create UIAxes1
            app.UIAxes1 = uiaxes(app.Tab);
            xlabel(app.UIAxes1, 't/s')
            ylabel(app.UIAxes1, 'Y')
            app.UIAxes1.PlotBoxAspectRatio = [4.3953488372093 1 1];
            app.UIAxes1.FontName = 'Arial';
            app.UIAxes1.FontWeight = 'bold';
            app.UIAxes1.XLim = [-Inf Inf];
            app.UIAxes1.YLim = [-Inf Inf];
            app.UIAxes1.XTickLabelRotation = 0;
            app.UIAxes1.YTickLabelRotation = 0;
            app.UIAxes1.YTickLabel = {'0'; '0.5'; '1'};
            app.UIAxes1.ZTickLabelRotation = 0;
            app.UIAxes1.Box = 'on';
            app.UIAxes1.XGrid = 'on';
            app.UIAxes1.YGrid = 'on';
            app.UIAxes1.TitleFontWeight = 'bold';
            colormap(app.UIAxes1, 'cool')
            app.UIAxes1.Position = [2 160 501 155];

            % Create Tab_2
            app.Tab_2 = uitab(app.TabGroup);
            app.Tab_2.Title = 'Frequency Spectrum';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.Tab_2);
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.PlotBoxAspectRatio = [1.77429467084639 1 1];
            app.UIAxes3.FontName = 'Arial';
            app.UIAxes3.FontWeight = 'bold';
            app.UIAxes3.XLim = [-Inf Inf];
            app.UIAxes3.YLim = [-Inf Inf];
            app.UIAxes3.XTickLabelRotation = 0;
            app.UIAxes3.YTickLabelRotation = 0;
            app.UIAxes3.ZTickLabelRotation = 0;
            app.UIAxes3.Box = 'on';
            app.UIAxes3.YGrid = 'on';
            colormap(app.UIAxes3, 'cool')
            app.UIAxes3.Position = [2 8 500 307];

            % Create Tab_3
            app.Tab_3 = uitab(app.TabGroup);
            app.Tab_3.Title = 'Envelope';

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.Tab_3);
            xlabel(app.UIAxes4, 't/s')
            ylabel(app.UIAxes4, 'Y')
            app.UIAxes4.FontName = 'Arial';
            app.UIAxes4.FontWeight = 'bold';
            app.UIAxes4.XLim = [-Inf Inf];
            app.UIAxes4.YLim = [-Inf Inf];
            app.UIAxes4.XTickLabelRotation = 0;
            app.UIAxes4.YTickLabelRotation = 0;
            app.UIAxes4.YTickLabel = {'0'; '0.5'; '1'};
            app.UIAxes4.ZTickLabelRotation = 0;
            app.UIAxes4.Box = 'on';
            app.UIAxes4.YGrid = 'on';
            colormap(app.UIAxes4, 'cool')
            app.UIAxes4.Position = [2 160 501 155];

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.Tab_3);
            xlabel(app.UIAxes5, 't/s')
            ylabel(app.UIAxes5, 'Y')
            app.UIAxes5.FontName = 'Arial';
            app.UIAxes5.FontWeight = 'bold';
            app.UIAxes5.XLim = [-Inf Inf];
            app.UIAxes5.YLim = [-Inf Inf];
            app.UIAxes5.XTickLabelRotation = 0;
            app.UIAxes5.YTickLabelRotation = 0;
            app.UIAxes5.YTickLabel = {'0'; '0.5'; '1'};
            app.UIAxes5.ZTickLabelRotation = 0;
            app.UIAxes5.Box = 'on';
            app.UIAxes5.YGrid = 'on';
            colormap(app.UIAxes5, 'cool')
            app.UIAxes5.Position = [2 8 501 155];

            % Create Label_11
            app.Label_11 = uilabel(app.UIFigure);
            app.Label_11.FontName = 'Arial';
            app.Label_11.FontSize = 16;
            app.Label_11.FontWeight = 'bold';
            app.Label_11.Position = [18 83 69 22];
            app.Label_11.HorizontalAlignment = 'right';
            app.Label_11.Text = 'Echo';

            % Create resound
            app.resound = uidropdown(app.UIFigure);
            app.resound.Items = {'0', '1000', '2000', '4000', '6000', '8000'};
            app.resound.ValueChangedFcn = createCallbackFcn(app, @resoundValueChanged, true);
            app.resound.FontWeight = 'bold';
            app.resound.Position = [94 80 110 28];
            app.resound.Value = '0';

            % Create human
            app.human = uibutton(app.UIFigure, 'state');
            app.human.ValueChangedFcn = createCallbackFcn(app, @humanValueChanged, true);
            app.human.Text = 'Vocal Reduce';
            app.human.BackgroundColor = [0.9686 0.6706 0.9686];
            app.human.FontName = 'Arial';
            app.human.FontSize = 14;
            app.human.FontWeight = 'bold';
            app.human.Position = [218 24 110 32];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MP3English

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
