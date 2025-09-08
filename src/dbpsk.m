%DBPSK: se usa por su simplicidad y robustez frente a fases 
%       aleatorias en un canal Rayleigh

%close all; % Cierra todas las gráficas

dataSize = 2500;                                                            % # bits de datos a transmitir
padding = 60;                                                               % Bits adicionales para manejar retardos de canal
fd1 = 1.25;                                                                 % Máx. desp. Doppler [Hz]

% Parámetros del canal
tau=[2000e-6 5000e-6 7000e-6];                                              % Retards
pdB=[-2 -3 0];                                                              % Potència 

% Inicializar variables para almacenar los resultados
minBERTotal = Inf;                                                          % Inicializar con un valor grande
bestfmInit = 0;                                                             % Almacenará el valor óptimo de frecuencia de muestreo

% Vectores para almacenar los resultados intermedios
fmInitValues = [];
BERTotalValues = [];

% Bucle for para variar fmInit
for fmInit = 12.5:1:300
    chan = comm.RayleighChannel('SampleRate', fmInit, 'MaximumDopplerShift', fd1, ...
        'PathDelays', tau, 'AveragePathGains', pdB);
    
    % Extraer el número de retardos
    informacioCanal = info(chan);                                           % Devuelve una estructura
    retard = informacioCanal.ChannelFilterDelay;                            % Valor escalar

    % Crear objetos mod/demod cada vez para evitar errores
    dbpskmod = comm.DBPSKModulator;  
    dbpskdemod = comm.DBPSKDemodulator;  

    % Crear, modular, transmitir, canal, recibir, desmodular
    dadesIN = randi([0 1], dataSize + padding, 1);                          % Sec. aleatoria creada
    dadesMOD = dbpskmod(dadesIN);                                           % Modular DBPSK sec dadesIN
    y = chan(dadesMOD);                                                     % Pasarlas por canal
    
    % Ajustar índices para compensar el retardo del canal
    dadesOUT = dbpskdemod(y(retard + 1:(dataSize + retard)));               % Demodular DBPSK

    % Calcular BERTotal
    [~, BERTotal] = biterr(dadesIN(1:dataSize), dadesOUT);

    % Actualizar el valor mínimo y la mejor fmInit
    if BERTotal < minBERTotal
        minBERTotal = BERTotal;
        bestfmInit = fmInit;
    end

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
xlabel('Frecuencia de muestreo [Hz]');
ylabel('BER [%]');
title('BER vs Frecuencia de muestreo');

%-----------------------------------------------
% Evaluación del BER frente a la SNR
%-----------------------------------------------

% Vectores para almacenar los resultados intermedios
dataSize = 10000;
padding = 60;

% Inicializar variables para almacenar los resultados
minBERTotal = Inf;
bestSNR = 0;

% Vectores para almacenar los resultados intermedios
SNRValues = [];
BERTotalValues = [];

for SNR = -40:1:40
    % Crear canal Rayleigh y AWGN
    chan = comm.RayleighChannel('SampleRate', 50, 'MaximumDopplerShift', fd1, ...
        'PathDelays', tau, 'AveragePathGains', pdB);
    awgnChannel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', ...
        'SNR', SNR);
    
    % Crear nuevos objetos mod/demod
    dbpskmod = comm.DBPSKModulator;  
    dbpskdemod = comm.DBPSKDemodulator;  

    % Crear, modular, transmitir, canal, recibir, desmodular
    dadesIN = randi([0 1], dataSize + padding, 1);
    dadesMOD = dbpskmod(dadesIN);
    
    % Paso por el canal Rayleigh
    canalNoSoroll = chan(dadesMOD);
    
    % Añadir ruido AWGN
    y = awgnChannel(canalNoSoroll);
    
    % Ajustar índices para compensar el retardo del canal
    dadesOUT = dbpskdemod(y(retard + 1:(dataSize + retard))); 

    % Calcular BERTotal
    [~, BERTotal] = biterr(dadesIN(1:dataSize), dadesOUT);

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
ylabel('BER');
title('BER vs SNR');
