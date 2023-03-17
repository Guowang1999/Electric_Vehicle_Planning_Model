warning off
clear all
clc
%% 开始参数设置
N=150                          %充电车数量
n=10                             %充电站个数
carnum_set=20            %电车容量
user_Creditd_set=0.9    %信誉度阈值
distant_set=0.9            %距离阈值
prince_set=0.9            %价格设置
Pw_set=60               %功率设置

Dij=rand(N,n)              %距离举证

Pij=rand(N,1)               %价格矩阵
Pij=repmat(Pij,1,10)       % 价格对于每一个站点都一样


C=rand(N,1)                  %用户信誉矩阵
C=repmat(C,1,10)           %对于每一个站点都是相同的信誉值


Q=rand(N,1)                 %充电站电车个数容量

Pw=rand(N,1)                %单个用户功率
Pw=repmat(Pw,1,10)       %对于每一个站点都是相同的功率

QC=10*rand(N,1)          %剩余电量


% keep()
%%  第二层优化   目标函数-撮合交易数量最多    位置调度决策矩阵   kij=0/1
%       
% num为电车数量，n为充电站数。
Constraints=[];
num=150;
x2=binvar(num,n)   %决策变量
%% 限制一：信誉度满足充电站要求
for j= 1 : num     
Constraints = [Constraints,0<=sum(C(j,:).*x2(j,:)) <= user_Creditd_set];
end
%% 限制二：距离满足用户要求
for j= 1 : num     
Constraints = [Constraints,0<=sum(Dij(j,:).*x2(j,:)) <= distant_set];
end
%% 限制三：价格满足用户要求
for j= 1 : num    
Constraints = [Constraints,0<=sum(Pij(j,:).*x2(j,:)) <= prince_set ];
end

%% 限制四：去用户预定的充电站

% 生成用户预约用户矩阵
T2=rand(num,10);
for i=1:num
 for j=1:10
   if T2(i,j)<=0.5
T2(i,j)=0;
   else
T2(i,j)=1;
   end
 end
end
T2=T2+1;
%限制等式

for j= 1 : num    
Constraints = [Constraints,0<=sum(T2(j,:).*x2(j,:)) <= 1 ];
end

%% 限制五：充电功率满足用户电车的需求
for j= 1 : 10   
Constraints = [Constraints,0<=sum(Pw(:,j).*x2(:,j)) <= Pw_set ];
end
%% 限制六：一辆车只去一个地方
for i = 1 : num
Constraints = [Constraints,0<=sum(x2(j,:))<= 1];
end
%% 任意站点之间车辆差距不会过大 

%% 目标函数
f= - sum(sum(x2));
%% 求解过程
options=sdpsettings('solver','cplex'); 
sol2=optimize(Constraints,f,options); 

%% 求解过程
if sol2.problem == 0
 % Extract and display value
 solution2 = value(x2)
 res=value(f)
 else
 display('Hmm, something went wrong!');
 end
%% 结果展示
y=sum(solution2,1)    %%计算充电地点的车辆数量
figure (1)
plot(y,'*-b','LineWidth',1.5)
hold on
bar(y)                       % y为 求解的24小时，每一个时间段的结果

sum(y)

