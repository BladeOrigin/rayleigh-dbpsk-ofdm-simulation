%fitxer per simular el canal

seqPN = genPNSequence([6 1 0],[0 0 0 0 0 1]);
mostres = 4;
NouseqPN = upsample(seqPN,mostres);
NouseqPN = filter([1 1 1 1], 1, NouseqPN);
%plot(NouseqPN);
dades = repmat(NouseqPN,1,200);%creem 200 vegades el canal
%plot (dades);

%fer un randi amb mumeros aleatoris 1000 mostres, dbpskmodulator o el que sigui modules aquestes dades amb dbpsk (mira la diferencia de fase l'antic amb el nou)
%mirem funcio ebiter(ber) i comparem les enviades al principi amb les
%rebudes i tindrem el ber, fer per diferents el bit rate (diferents fm) i
%mirar quina va millor
%fd es agafar l'amplada i dividir-la entre 2. Per calcular lo demés agafem
%els valors directament de les gràfiques i ho fem (Si la potencia es 300 i el retard 50, ho fiquem a la formula i ja)
%1 mostra = 1/fm

%abans de demodular hem de treure el retard amb funció info i retorna
%channel filtre delay que es el num de mostres que hem de treure, despres
%demodular i restar 
%ber limit de 0,1 i despres grafica snr, despres ofdm 1 modules
%subportadores 2 ofdm 3 passes per canal + retard 4 demodules ofdm 5 demodules
%subportadores
%Amb multicami
fm = 20000;
fd1 = 2; %Hz 
tau = [0 2300e-6 4600e-6];%vector de retards / e-6correspon a milisegons
pdb = [-6 0 -6];%vector de potencia en dB
chan = comm.RayleighChannel('SampleRate',fm,'MaximumDopplerShift',fd1,'PathDelays',tau,'AveragePathGains',pdb);%doppler/retard/eixamplació temporal
y = chan(dades');%filtrem les dades pel canal
plot(abs(y),'b--');  %plot del valor absolut
correl = xcorr(y,NouseqPN); %correlacio creuada
plot(abs(correl),'r-')

%Matriu de canal (mostrar la grafica unicament on transmet)
correl_util = correl(length(dades)-10:2*length(dades)-11);
plot(abs(correl_util));
matriu_canal=reshape(correl_util,length(NouseqPN),200)';%converteix el vector correl_util en una matriu de les dos seguents variables
imagesc(abs(matriu_canal));%pita la matriu en una imatge de color / matriu de correlacio temporal/cada linia horitzontal es una correlació de canal
figure;
mesh(abs(matriu_canal));%grafica 3D

%Funcio scattering
for i=1:length(NouseqPN)
    Fscatt(:,i) = fftshift(fft(matriu_canal(:,i))); %la ffshift desplaça tot 10 posicions
end
figure;
imagesc(abs(Fscatt));
%figure;
mesh(abs(Fscatt));%les montanyes son l'aspectre doppler

%Funcio de transferencia (resposta en frequencia del canal
for i=1:200
    Ftransf(i,:) = fftshift(fft(matriu_canal(i,:))); %la ffshift desplaça tot 10 posicions
end
figure;
imagesc(abs(Ftransf));
figure;
mesh(abs(Ftransf));%la montaña es el ample en frequencia del canal



%dbpsk
%close all; % tanca totes les grafiques

dataSize = 1000;
padding = 60;
fd1 = 2;
dbpskmod = comm.DBPSKModulator;
dbpskdemod = comm.DBPSKDemodulator;

% Vectores para almacenar los resultados intermedios
fmInitValues = [];
BERTotalValues = [];

% Parámetros del canal
tau = [0 2300e-6 4600e-6];
pdB = [-6 0 -6];

% Inicializar variables para almacenar los resultados
minBERTotal = Inf; % Inicializar con un valor grande
bestfmInit = 0;

% Bucle for para variar fmInit
for fmInit = 20:10:300
    chan = comm.RayleighChannel('SampleRate', fmInit, 'MaximumDopplerShift', fd1, 'PathDelays', tau, 'AveragePathGains', pdB);
    informacioCanal = struct2cell(info(chan));
    retard = informacioCanal{1};

    % Crear, modular, transmitir, canal, recibir, desmodular
    dadesIN = randi([0 1], dataSize + padding, 1);
    dadesMOD = dbpskmod(dadesIN);
    y = chan(dadesMOD);
    dadesOUT = dbpskdemod(y(retard + 1:(dataSize + retard), :));

    % Calcular BERTotal
    [~, BERTotal] = biterr(dadesIN(1:dataSize, :), dadesOUT);

    % Actualizar el valor mínimo y la mejor fmInit
    if BERTotal < minBERTotal
        minBERTotal = BERTotal;
        bestfmInit = fmInit;
    end

    % Puedes hacer algo con los resultados intermedios si lo deseas
    disp(['fmInit: ', num2str(fmInit), ', BERTotal: ', num2str(BERTotal)]);
    % Almacenar resultados intermedios
    fmInitValues = [fmInitValues, fmInit];
    BERTotalValues = [BERTotalValues, BERTotal];
end

% Mostrar los resultados finales
disp(['Mejor fmInit: ', num2str(bestfmInit), ', BERTotal mínimo: ', num2str(minBERTotal)]);
% Graficar los resultados
figure;
plot(fmInitValues, BERTotalValues, '-r');
grid on;
xlabel('Freqüència de mostreig [Hz]');
ylabel('BER [%]');
title('BER amb diferents fm');

%SNR
%Quant mes a prop del doppler, mes error tambe
% Vectores para almacenar los resultados intermedios
dataSize = 10000;
padding = 60;
dbpskmod = comm.DBPSKModulator;
dbpskdemod = comm.DBPSKDemodulator;

% Parámetros del canal
tau = [0 2300e-6 4600e-6];
pdB = [-6 0 -6];

% Inicializar variables para almacenar los resultados
minBERTotal = Inf;
bestSNR = 0;

% Vectores para almacenar los resultados intermedios
SNRValues = [];
BERTotalValues = [];
% Bucle for para variar SNR
for SNR = -20:1:40
    % Crear canal AWGN con la SNR actual

    chan = comm.RayleighChannel('SampleRate', 100, 'MaximumDopplerShift', fd1, 'PathDelays', tau, 'AveragePathGains', pdB);
    awgnChannel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SNR', SNR);
    
    % Crear, modular, transmitir, canal AWGN, recibir, desmodular
    dadesIN = randi([0 1], dataSize + padding, 1);
    dadesMOD = dbpskmod(dadesIN);
    canalNoSoroll = chan(dadesMOD);
    y = awgn(canalNoSoroll,SNR);
    dadesOUT = dbpskdemod(y(retard + 1:(dataSize + retard), :));

    % Calcular BERTotal

    [~, BERTotal] = biterr(dadesIN(1:dataSize, :), dadesOUT);

    % Almacenar resultados intermedios
    SNRValues = [SNRValues, SNR];
    BERTotalValues = [BERTotalValues, BERTotal];
end

% Mostrar los resultados finales
disp(['Mejor SNR: ', num2str(bestSNR), ', BERTotal mínimo: ', num2str(minBERTotal)]);

% Graficar los resultados
figure;
plot(SNRValues, BERTotalValues, '-r');
grid on;
xlabel('SNR (dB)');
ylabel('BERTotal');
title('BERTotal vs SNR');

%SNR per sota de 0,1 es no se quan ber