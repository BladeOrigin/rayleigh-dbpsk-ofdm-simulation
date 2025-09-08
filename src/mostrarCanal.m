function mostrarCanal(seqPN, graphTitle)
    % Funció per mostrar gràfiques de seqüències
    plot(seqPN, 'b'); % Mostra la seqüència PN original
    title(graphTitle); % Assigna el títol passat com a argument
    xlabel('Índex');
    ylabel('Valor');
    grid on; % Afegeix la graella al gràfic
    axis tight; % Ajusta els límits del gràfic
end
