clear;clc   % 清空變數暫存, 清空畫面

% 準備讀寫檔, 檔名視情況調整
fid = fopen('ML_Final_02.inp','r');
fod = fopen('ML_Final_02.out','w');

% 看題目要什麼, 自行調整
fprintf(fod,'日期    平均氣壓   氣壓標準差   平均溫度   溫度標準差   平均風速   風速標準差   平均風向   風向標準差   最大風速   總日照時數\n');
fprintf(fod,'yyyymd   (hPa)                   (℃)                     (m/s)                    (deg)                 (m/s)        (hr)  \n');
% (下面格式要對齊 TMD難調~


% 日期初始化, 單純程式執行需要
date = 0;

% 鏈結串列初始化~XD, 不懂沒關係, 當作一種技巧~
wind_speed = [];
wind_deg_AVG =[];
wind_speed_AVG = [];


while(~feof(fid))   % 讀到整個檔案讀完, EOF = End Of File, 還沒結束時feof(fid)會回傳false
    

    % 以下處理不管"數據"有幾個都可以讀
    str = fgetl(fid);   % 先把一行數據全部當字串讀
    result = sscanf(str,'%f');  % 讓電腦從字串中自己讀出一個一個的浮點數, result是個"陣列" 
                                % 別再學"他"說矩陣啦!一點都不專業!


    if length(result)   % 如果有讀到的浮點數 陣列長度會大於1, 反之就是讀到字串了
                        %  在電腦中只要不是 0 都是Ture
                        
        if result(1) ~= date    % 如果日期沒換就保存資料, 換日期了就計算並產出資料
                                % https://i.imgur.com/RGbeTZp.png
                                % result(1)是因為陣列的第一格是存放日期或是說第一個讀到的浮點數是日期
            

            if date % 第一次執行不用輸出, date第一次執行的時候為0
                [wind_speed_AVG,wind_deg_AVG] = output(fod,data,wind_speed_AVG,wind_deg_AVG);   %上次的資料可以輸出了
            end
            data = cell(1,length(result)-2);    % 產生一個cell長度為 length(result)-2, 等等裝數據用
            date = result(1);   % 前面得 result(1) ~= date, date 要更新啊~
        end


        % 從3開始是因為 第一項是"日期" 第二項是"小時"
        for i  = 3:length(result)   % 收集要計算的資料, 這邊的每種資料都會算它的STD AVG SUM
            if result(i) ~= -9999   % 如果為有效值

                % 大二資料結構, 簡易實作鏈結串列XD
                data(1,i-2) = {[cell2mat(data(1,i-2)),result(i)]};  % 放進方便計算的東西中XDDD, 自己忘記怎麼轉型的了
                
                % 這項的計算方法跟其他人不同, 特別處理
                if i == 8
                    wind_speed = [wind_speed,result(i)];    % 又再鍊節串列~ pushback
                end
            end
         end
    end

    % 如果要跟輸入檔一樣上面要有, St_name, ST_No, No_data 可以把註解拿掉就可以用了
    % https://i.imgur.com/nZLP3Mn.png
    %fprintf(fod,'%s\n',str);
end

[wind_speed_AVG,wind_deg_AVG] = output(fod,data,wind_speed_AVG,wind_deg_AVG);    % 最後一次的資料還沒輸出, 輸出一下

% 關閉讀檔
fclose(fid);
fclose(fod);

wind_deg_AVG = 270-wind_deg_AVG;    % 風向的轉換, 因為方位角計算與機器不同所以要轉換


% 輸出function
function [wind_speed_AVG,wind_deg_AVG] = output(fod,D,wind_speed_AVG,wind_deg_AVG)
    
    % 丟到自己寫的函式裡面計算平均值, 標準差, 加總
    [AVG,STD,SUM,maximum] = ML_00681054_fn_2(D);

    % 好像要更其他天的數據一起算, 所以要更新並回傳, 有點忘了
    wind_speed_AVG = [wind_speed_AVG,AVG(6)];   
    wind_deg_AVG =[wind_deg_AVG,AVG(7)];
    % ===============================================

    % 真正寫入檔案,(要寫入的資料都到齊了), 這邊就是重點的對照資料的順序, 填入正確的數字, 就前面都不懂也沒關係了(理論上前面所有數據都有算AVG STD SUM maximum, 所以數字填對就結束了)
    fprintf(fod,'%d %5.2f     %5.2f       %5.2f      %5.2f        %5.2f      %5.2f      %5.2f       %5.2f      %.2f      %.2f\n',date,AVG(2),STD(2),AVG(1),STD(1),AVG(6),STD(6),AVG(7),STD(7),maximum(8),SUM(12));
end


% 手寫的平均值, 標準差, 加總, 考試的一部份
function [AVG,STD,SUM,maximum] = ML_00681054_fn_2(D)
    
    % 又是鏈結串列實作囉~
    % 先開空陣列
    AVG = [];
    STD = [];
    SUM =[];
    maximum = [];

    % pushback, 把節點(資料)一個一個串起來~
    for i =1:length(D)
        AVG = [AVG,mean(cell2mat(D(1,i)))];
        STD = [STD,std(cell2mat(D(1,i)))];
        SUM = [SUM,sum(cell2mat(D(1,i)))];
        maximum = [maximum,max(cell2mat(D(1,i)))];
    end
    
end
