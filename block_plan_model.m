warning off
clear all
clc
%% 开始参数设置
N=200                          %充电车数量
n=10                             %充电站个数
carnum_set=20            %电车容量
user_Creditd_set=0.7    %信誉度阈值
distant_set=0.5             %距离阈值
prince_set=0.5             %价格设置
Pw_set=1.5                   %功率设置

Dij=rand(N,n)              %距离举证                                                                                                                                                                                                                                                                                                                                         

Pij=rand(N,n)               %价格矩阵   

C=rand(N,1)                  %用户信誉矩阵

Q=rand(N,1)                 %充电站电车个数容量

Pw=rand(N,1)                %单个用户功率

QC=10*rand(N,1)          %剩余电量

%% 电车预约时间,生成0-1随机矩阵。
T=rand(N,24);
for i=1:N
 for j=1:24
   if T(i,j)<=0.1
T(i,j)=0;
   else
T(i,j)=1;
   end
 end
end
T=T+1;

%%     第一层优化   目标函数-使得剩余电量得到最大化利用  时间调度决策矩阵  Sij=0/11 
%        参数设置    
%      1. 第j时间段的调度车辆不能超过总体容量/2.在用户选定的时间段进行调度。/3.Sij叠加唯一=1
num=200
time=24
x=binvar(num,time,'full')

%%   限制一：每一辆车最多去往一个地点
Constraints=[]
t1=sum(x,2)
for i = 1 : num
Constraints = [Constraints,t1(i)<= 1];
end
%%   限制二：每个充电站不超过其充电站的容量
t2=sum(x,1)
for j= 1 : time
 Constraints = [Constraints, t2(j) <=15];
end
%%   限制三：在预定的时间去充电站
for i = 1 : num
  Constraints = [Constraints, sum(x(i,:).*T(i,:))<=1];
end

%% 定义优化目标，- 号代表求最大值
f= - (sum(sum(x)));
%% 求解过程
options=sdpsettings('solver','cplex'); 
sol=optimize(Constraints,f,options); 

if sol.problem == 0 % problem =0 代表求解成功
   solution = value(x)
   res=value(f)
else
    disp('求解出错');
end

%% 作图一：24小时调度的车辆
y=sum(solution,1)    %%计算24小时每个时段的车辆数量
figure (1)

% bar(y)                       % y为 求解的24小时，每一个时间段的结果
% hold on
plot(y,'*-r','LineWidth',1.5)
xlabel('时间段(h)')
ylabel('撮合电车数量(辆)')

%% 作图二：第一次调度下-24小时调度的车辆所需用电量
y1=zeros(24,1)
for i=1:24
    
    y1(i,1)=sum(Pw.*x(:,i))

end
hold on
plot(y1,'*-c','LineWidth',1.5)

 
