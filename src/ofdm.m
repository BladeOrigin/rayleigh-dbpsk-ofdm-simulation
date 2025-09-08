close all;

% Configuració inicial
numSubcarriers = 8;                                                         % Nombre de subportadores
cpLength = 0;                                                               % Longitud del prefix cíclic - Sempre a 0
numBits = 10000;                                                            % Nombre total de bits (igual a símbols)
numBitsAdd = numBits + 10;
numSymbols = 10000; 

% Configuració canal
fp=7296000;
fm=200;                                                                     % Cada subportadora va a 200/8 = 25Hz
fd1=1.25;
tau=[2000e-6 5000e-6 7000e-6];                                              % Retards
pdb=[-2 -3 0];                                                              % Potència

% Generació de seqüència aleatòria de bits per subportadora
data = randi([0 1], numSubcarriers, numBitsAdd);                            % Seqüència aleatòria de bits (una fila per subportadora)

% Modulació DPSK per subportadora
modulatorDPSK = comm.DPSKModulator('BitInput', true, 'ModulationOrder', 2); % Modulador DPSK (Log 2 - 1 bit per simbol (amb dbpsk seria un 4))
demodulatorDPSK = comm.DPSKDemodulator('BitOutput', true, 'ModulationOrder', 2); % Desmodulador DPSK
dataSymbols = zeros(numSubcarriers, numBitsAdd,1);                          % Preal·locació de símbols modulats

for i = 1:numSubcarriers
    dataSymbols(i, :) = modulatorDPSK(data(i, :).');                        % Modular cada fila (subportadora)
end

% Ajust per a OFDMModulator (dimensions requerides)
%dataSymbols = permute(dataSymbols, [1, 3, 2]);                             % Reorganitza dimensions: [FFTLength x 1 x NumSymbols]

% Configuració de l'OFDMModulator amb NumGuardBandCarriers explícit
ofdmModulator = comm.OFDMModulator('FFTLength', numSubcarriers, ...
                                   'NumGuardBandCarriers', [0; 0], ...
                                   'CyclicPrefixLength', cpLength,'NumSymbols',numSymbols + 10);

ofdmDemodulator = comm.OFDMDemodulator('FFTLength', numSubcarriers, ...
                                       'NumGuardBandCarriers', [0; 0], ...
                                       'CyclicPrefixLength', cpLength,'NumSymbols',numSymbols);
% Inicializar variables para almacenar los resultados
minBERTotal = Inf;                                                          % Inicializar con un valor grande
bestfmInit = 0;                                                             % Almacenará el valor óptimo de frecuencia de muestreo

% Vectores para almacenar los resultados intermedios
fmInitValues = [];
BERTotalValues = [];

% Bucle for para variar fmInit
%for fmInit = 50.5:1:1500
%     chan = comm.RayleighChannel('SampleRate',fmInit,...
%     'MaximumDopplerShift',fd1,...
%     'PathDelays',tau,...
%     'AveragePathGains',pdb);
%     awgnChannel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', ...
%         'SNR', SNR);
% 
%     % Generació del senyal OFDM
%     ofdmSignal = ofdmModulator(dataSymbols);                              % Modulació OFDM
%     
%     % Recepció del senyal OFDM (sense canal ni soroll)
%     rxSignal = chan(ofdmSignal);                                          % Senyal rebut = senyal transmès
%      delay = info(chan).ChannelFilterDelay;
%      rxSignalSync = rxSignal(delay+1:(end-(80-delay)));                   %10bits de retard x 8 portadores = 80
%     
%     % Demodulació OFDM
%     receivedSymbols = ofdmDemodulator(rxSignalSync);                      % Demodulació OFDM
%     receivedSymbols = permute(receivedSymbols, [1, 3, 2]);                % Reorganitza dimensions: [Subcarriers x Symbols]
%     
%     % Desmodulació DPSK per subportadora
%     rxBits = zeros(size(receivedSymbols));                                % Preal·locació per als bits rebuts
%     
%     for i = 1:numSubcarriers
%         rxBits(i, :) = demodulatorDPSK(receivedSymbols(i, :).');          % Desmodular cada fila (subportadora)
%     end
%     
%     % Càlcul de BER
%     [~, ber] = biterr(data(1:numBits), rxBits(1:numBits));                % Compara tots els bits originals amb els rebuts
% 
%      % Actualizar el valor mínimo y la mejor fmInit
%     if ber < minBERTotal
%         minBERTotal = ber;
%         bestfmInit = fmInit;
%     end
% 
%     disp(['fmInit: ', num2str(fmInit), ', BERTotal: ', num2str(ber)]);
%     
%     % Almacenar resultados intermedios
%     fmInitValues = [fmInitValues, fmInit];
%     BERTotalValues = [BERTotalValues, ber];
% end

% Mostrar los resultados finales BER vs. Freq
%disp(['Mejor fmInit: ', num2str(bestfmInit), ', BERTotal mínimo: ', num2str(minBERTotal)]);
% Graficar los resultados
%figure;
%plot(fmInitValues, BERTotalValues, '-r');
% grid on;
% xlabel('Frecuencia de muestreo [Hz]');
% ylabel('BER [%]');
% title('BER vs Frecuencia de muestreo');
% 
% % Resultats
% disp(['BER (OFDM sense canal ni soroll, usant DPSK per subportadora): ', num2str(ber)]);

% Inicializar variables para almacenar los resultados
minBERTotal = Inf;
bestSNR = 0;

% Vectores para almacenar los resultados intermedios
SNRValues = [];
BERTotalValues = [];

for SNR = -40:1:40
    chan = comm.RayleighChannel('SampleRate',170,...
    'MaximumDopplerShift',fd1,...
    'PathDelays',tau,...
    'AveragePathGains',pdb);
    awgnChannel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', ...
        'SNR', SNR);

    % Generació del senyal OFDM
    ofdmSignal = ofdmModulator(dataSymbols);                                % Modulació OFDM
    
    % Recepció del senyal OFDM (sense canal ni soroll)
    rxSignal = chan(ofdmSignal);                                            % Senyal rebut = senyal transmès
    delay = info(chan).ChannelFilterDelay;
    rxSignal = awgnChannel(rxSignal);
    rxSignalSync = rxSignal(delay+1:(end-(80-delay)));                      % 10bits de retard x 8 portadores = 80
    
    % Demodulació OFDM
    receivedSymbols = ofdmDemodulator(rxSignalSync);                        % Demodulació OFDM
    receivedSymbols = permute(receivedSymbols, [1, 3, 2]);                  % Reorganitza dimensions: [Subcarriers x Symbols]
    
    % Desmodulació DPSK per subportadora
    rxBits = zeros(size(receivedSymbols));                                  % Preal·locació per als bits rebuts
    
    for i = 1:numSubcarriers
        rxBits(i, :) = demodulatorDPSK(receivedSymbols(i, :).');            % Desmodular cada fila (subportadora)
    end
    
    % Càlcul de BER
    [~, ber] = biterr(data(1:numBits), rxBits(1:numBits));                  % Compara tots els bits originals amb els rebuts

    % Almacenar resultados intermedios
    SNRValues = [SNRValues, SNR];
    BERTotalValues = [BERTotalValues, ber];
end

% Gràfica de validació
figure;
subplot(2, 1, 1);
plot(real(ofdmSignal(1:numBits)), 'b');
title('Senyal OFDM Transmès (temps)');
xlabel('Mostres');
ylabel('Amplitud');

subplot(2, 1, 2);
plot(real(rxSignal(1:numBits)), 'r');
title('Senyal OFDM Rebut (temps)');
xlabel('Mostres');
ylabel('Amplitud');

% Mostrar los resultados finales
disp(['Mejor SNR: ', num2str(bestSNR), ', BERTotal mínimo: ', num2str(minBERTotal)]);

% Graficar los resultados SNR
figure;
plot(SNRValues, BERTotalValues, '-r');
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('BER vs SNR');