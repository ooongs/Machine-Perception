function varargout = lab1(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lab1_OpeningFcn, ...
                   'gui_OutputFcn',  @lab1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before lab1 is made visible.
function lab1_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for lab1
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = lab1_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global audio;
global fs;
[file,~] = uigetfile();         % 选择音频样本
[audio,fs] = audioread(file);   % 读入音频信息
audio = audio(:,1);             % 若有两个以上的信道，则选择其中的第一道

axes(handles.axes1)             
t = (0:length(audio)-1)/fs;     % 时间轴
plot(t,audio);                  % 显示时域特性
xlabel('时间(s)'); ylabel('幅度');

axes(handles.axes2)
nw = 128;                                           % 窗口长度
window = hamming(nw);                               % 窗口
noverlap = 120;                                     % 重叠样本数
nfft = 2^nextpow2(length(window));                  % DFT点数
spectrogram(audio,window,noverlap,nfft,fs,'yaxis'); % 直接显示时频特性
xlabel('时间(s)'); ylabel('频率(Hz)'); % title('nw = 512'); 


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global audio;
global fs;

player = audioplayer(audio,fs);         % 将音频信号转换成audioplayer对象
frame_len = 0.1;                        % 帧长为0.1s
ylim = max(abs(audio));                 % 信号的绝对值之最大值，用于确定时域波形的竖轴范围
half_frame = round(frame_len*fs/2);     % 用于表示正在处理的帧的时间范围

pause(frame_len); play(player);         % 停顿一段时间后播放声音

% 定义定时器
% StartDelay值为0，启动时没有延时
% TimerFcn为定时器被触发时执行的函数，这里指定为audio_plot()，显示正在处理的音频信号的时域波形和频谱波形
% BusyMode为drop表示当定时器需要执行TimerFcn，但前一次的TimerFcn仍然在执行的时候，不执行当前TimerFcn
% ExecutionMode为fixedSpacing表示定时器的触发方式为循环触发且前后两次被加入到执行语句队列时刻之间的间隔
% Period为TimerFcn的执行周期，这里为帧长frame_len
my_Timer = timer('StartDelay',0,'TimerFcn',@(~,~) audio_plot(player,half_frame,ylim,handles),'BusyMode','drop','ExecutionMode','fixedSpacing','Period',frame_len);

start(my_Timer)             % 启动定时器
pause(length(audio)/fs+2)   % 等待至声音播放结束
delete(my_Timer)            % 删除定时器


function audio_plot(player,half_frame,ylim,handles)
global audio;
global fs;

% 计算左右侧索引
l = max(1,player.CurrentSample - half_frame); 
r = min(length(audio),player.CurrentSample + half_frame);
frame = audio(l:r);
t = ([l:r]-1)/fs;
if l==1
    frame = [zeros(1,r-l+1),frame]; 
    t = [(2*l-r-1:l-1)/fs,t];
end
if r==length(audio)
    frame = [frame,zeros(1,r-l+1)];
    t = [t,(r+1:2*r-l+1)/fs];
end

axes(handles.axes3) % 当前时域波形
plot(t,frame); set(gca,'xlim',[t(1) t(end)],'ylim',[-ylim ylim]);
xlabel('时间(s)'); ylabel('幅值');

axes(handles.axes4) % 当前频谱波形
len = length(frame);                % 信号长度            
mag = abs(fftshift(fft(frame)));    % 频谱幅度为|F(e^jw)|
mag = mag/max(mag);                 % 归一化
f = [0:len/2]*fs/len;               % 所画频谱横坐标范围为[0:fs/2]
plot(f,mag(round(len/2):len));
xlabel('频率(Hz)'); ylabel('幅值');
