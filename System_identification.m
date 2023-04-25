clear;close all;clc;

load('iddata-10.mat');

N = length(id.InputData);
m = 3; na = 2; nb = na; %nk=1 : valoare folosita ca implicita in cod
matricePuteri = generarePuteri(m, na, nb);

matriceSemnale = zeros(N, na); 
Phi = zeros(N, size(matricePuteri, 1));
matriceSemnalep = zeros(N, na); 
Phip = zeros(N, size(matricePuteri, 1));
y_hat_simulare=zeros(N,1);
matriceSemnales = zeros(N, na); 
Phis = zeros(N, size(matricePuteri, 1));

%Predictie identificare si validare

for k = 1 : N
    for i = 1 : na + nb
         if i < na + 1
             if k - i > 0
                 matriceSemnale(k, i) = id.OutputData(k - i);
                 matriceSemnalep(k, i) = val.OutputData(k - i);
            else
                 matriceSemnale(k, i) = 0;
                 matriceSemnalep(k, i) = 0;
             end

         else
            if k - i + na > 0
                matriceSemnale(k, i) = id.InputData(k - i + na);
                matriceSemnalep(k, i) = val.InputData(k - i + na);
            else
                matriceSemnale(k, i) = 0;
                matriceSemnalep(k, i) = 0;
            end
         end
    end
    for i = 1 : size(matricePuteri, 1)
        Phi(k, i) = prod(matriceSemnale(k, :) .^ matricePuteri(i, :));
        Phip(k, i) = prod(matriceSemnalep(k, :) .^ matricePuteri(i, :));
    end
end
if m==1
    Phi(:,1)=0;
    Phip(:,1)=0;
end
Theta = Phi \ id.OutputData;

% iesirea aproximata de identificare - predictie
y_hat_identificare=Phi * Theta;
% iesirea aproximata de identificare - simulare
for k = 1 : N
    for i = 1 : na + nb
         if i < na + 1
             if k - i > 0
                 matriceSemnaleid(k, i) = y_hat_simulare_id(k - i);
            else
                 matriceSemnaleid(k, i) = 0;
             end

         else
            if k - i + na > 0
                matriceSemnaleid(k, i) = id.InputData(k - i + na);
            else
                matriceSemnaleid(k, i) = 0;
            end
         end
    end
    for i = 1 : size(matricePuteri, 1)
        Phi2(k, i) = prod(matriceSemnaleid(k, :) .^ matricePuteri(i, :));
    end
    if m==1
    Phi2(:,1)=0;
    end
    y_hat_simulare_id(k)=Phi2(k,:)*Theta;
end


%predictie
y_hat_predictie = Phip * Theta;

%simulare

for k = 1 : N
    for i = 1 : na + nb
         if i < na + 1
             if k - i > 0
                 matriceSemnales(k, i) = y_hat_simulare(k - i);
            else
                 matriceSemnales(k, i) = 0;
             end

         else
            if k - i + na > 0
                matriceSemnales(k, i) = val.InputData(k - i + na);
            else
                matriceSemnales(k, i) = 0;
            end
         end
    end
    for i = 1 : size(matricePuteri, 1)
        Phis(k, i) = prod(matriceSemnales(k, :) .^ matricePuteri(i, :));
    end
    if m==1
    Phis(:,1)=0;
    end
    y_hat_simulare(k)=Phis(k,:)*Theta;
end


%mse
for i=1:N
err_pred(i)=(val.y(i)-(y_hat_predictie(i))');
err_sim(i)=(val.y(i)-(y_hat_simulare(i))');
err_id(i)=(id.y(i)-(y_hat_identificare(i))');
err_id2(i)=(id.y(i)-(y_hat_simulare_id(i))');
MSE_pred(i)=1/N*(err_pred(i)).^2;
MSE_sim(i)=1/N*(err_sim(i)).^2;
MSE_id(i)=1/N*(err_id(i)).^2;
MSE_id2(i)=1/N*(err_id2(i)).^2;
end
err_pred1=sum(MSE_pred);
err_sim1=sum(MSE_sim);
err_id1=sum(MSE_id);
err_id2=sum(MSE_id2);

%plots
%Identificare:
figure; 
subplot(1,2,1)%Predictie
plot(id.y);
hold on
plot(y_hat_identificare);
subtitle("Identificare: MSE predictie = " + err_id1 )
subplot(1,2,2)%Simulare
plot(id.y);
hold on
plot(y_hat_simulare_id);
subtitle("Identificare: MSE simulare = " + err_id2 )
%Validare:
figure;
subplot(1,2,1); %Predictie
plot(val.OutputData)
hold on
plot(y_hat_predictie)
legend('y val', 'y predictie')
title("Model vs Predictie : MSE = "+err_pred1)
subplot(1,2,2); %Simulare
plot(val.OutputData)
hold on
plot(y_hat_simulare)
legend('y val', 'y simulare')
title("Model vs Simulare : MSE = "+err_sim1)
%Validare predictie + simulare
figure;
plot(val.OutputData)
hold on
plot(y_hat_predictie)
hold on
plot(y_hat_simulare)
legend('y val', 'y predictie','y simulare')
title('Validare VS Predictie VS Simulare')

%functie generare
function matricePuteri = generarePuteri(m, na, nb)
    ultimaLinie = zeros(1, na + nb); %prima combinatie
    matricePuteri = ultimaLinie;
    NrCombinatii = m + 1; %numarul primelor combinatii (o singura coloana din matrice completata)
    NrCombinatiiNoi = 0;

    for i = 1 : na + nb
        while sum(ultimaLinie) < m
            ultimaLinie(i) = ultimaLinie(i) + 1;
            matricePuteri = [matricePuteri; ultimaLinie];

            if i ~= 1 %pentru i == 1 nu exista combinatii anterioare
                NrCombinatiiNoi = NrCombinatiiNoi + 1;
                ultimaLinieNemodificata = ultimaLinie;
                linieGeneratoare = ultimaLinie(i : end); %generare combinatii in functie de combinatiile anterioare
                for j = 2 : NrCombinatii %verifica toate combinatiile anterioare
                    linieAnterioara = matricePuteri(j, :);
                    linieAnterioara = linieAnterioara(1 : i - 1);
                    ultimaLinie = [linieAnterioara , linieGeneratoare]; %se lipeste partea prelucrata a combinatiilor anterioare cu linia generatoare

                    if sum(ultimaLinie) <= m
                        matricePuteri = [matricePuteri; ultimaLinie];
                        NrCombinatiiNoi = NrCombinatiiNoi + 1;
                    end
                end
                ultimaLinie = ultimaLinieNemodificata;%se continua incrementarea cu 1 de la ultima linie
            end  
        end
        NrCombinatii = NrCombinatii + NrCombinatiiNoi;
        NrCombinatiiNoi = 0;
        ultimaLinie(i) = 0;
    end
end














