 %%Fitxer per simular el canal

close all

seqPN =genPNSequence([6 1 0], [0 0 0 0 0  1]);
plot(seqPN, 'r');
mostres=4;
nouSeqPN = upsample(seqPN,mostres);
nouSeqPN = filter([1 1 1 1],1,nouSeqPN);

%plot(NouSeqPN)

%%Repetir la seqüència pm per analitzar-la diverses vegades
dades=repmat(nouSeqPN,1,1000);
%plot(dades);

%%%%Passar la seqüència pel canal%%%%

%%Sense multipath
fp=7296000;
fm=10000;
fd1=1.25;
chan=comm.RayleighChannel('SampleRate',fm,'MaximumDopplerShift',fd1);       % Canals que NO tenen visió directa, si en tenen: canal de Rise
y=chan(dades');

%%Amb multipath
fp=7296000;
fm=10000;
fd1=1.25;

%%Com no ens diuen els retards -> Anar variant potència fins que la
%%formula doni 2-2.5 d'eixamplament temporal. Els temps de retard son 
%%1ms, 2ms, 5ms

tau=[2000e-6 5000e-6 7000e-6]; %Retards
pdb=[-2 -3 0]; %potència - por la cara
chan = comm.RayleighChannel('SampleRate',fm,...
    'MaximumDopplerShift',fd1,...
    'PathDelays',tau,...
    'AveragePathGains',pdb);
y=chan(dades');
%plot(abs(y))

%%Correlació: ens dóna la resposta impulsional del canal
correl=xcorr(y,nouSeqPN);                                                   % Hem passat pel canal
%correl=xcorr(dades',nouSeqPN);                                             % NO hem passat pel canal
plot(abs(correl));    


%%%%Extreure informació del sondeig%%%%%

%%Eliminar la part inicial on només hi ha 0
correl_util=correl(length(dades)-10:2*length(dades)-11);
plot(abs(correl_util));

%%Generem la matriu del canal: per analitzar el canal
matriu_canal=reshape(correl_util,length(nouSeqPN),1000)';
imagesc(abs(matriu_canal));                                                 % Barres vericals, fons blau
figure;
mesh(abs(matriu_canal));                                                    % 3D, pared 4 colors

%%Afegim la funció de scattering: fa la transformada de Fourier en l'eix de
%%l'eixamplament temporal (eix de la variació temporal) i per tant veiem
%%l'espectre doppler
Fscatt = zeros(size(matriu_canal, 1), length(nouSeqPN));                    % Inicializa con dimensiones adecuada
for i=1:length(nouSeqPN)
    Fscatt(:,i)=fftshift(fft(matriu_canal(:,i)));
end


figure();
mesh(abs(Fscatt));                                                          % Pinchitos
figure();
imagesc(abs(Fscatt));                                                       % AZUL

%Funcio de transferencia (resposta en frequencia del canal
for i=1:1000
    Ftransf(i,:) = fftshift(fft(matriu_canal(i,:)));                        % La ffshift desplaça tot 10 posicions
end
figure;
imagesc(abs(Ftransf));
figure;
mesh(abs(Ftransf));

%la montaña es el ample en frequencia del canal 
%Eixamplament temporal del canal en el dominni frequencial, dona el BW de Coherència (fo)
%La matriu del canal ens dona tota la informació (cada eix ens diu algo)
    %Aláda -> Potencia
    %Eix pared -> Variacio temporal
    %Eix no pared (pics) -> Numero de camins -> Eixamplament temporal

