% A velocidade de propagação das ondas sonoras depende da massa volúmica e da
% rigidez do material, sendo a velocidade de propagação das ondas longitudinais, aproximadamente, duas
% vezes maior que a velocidade de propagação das ondas transversais. Nos laminados em material
% compósito, a rigidez altera de uma direção para a outra, dependendo da orientação da fibra. Assim, a
% velocidade das ondas sonoras neste tipo de materiais é diferente em direções distintas.

%% Inicialização e Propriedades dos Materiais

clc; clear; close all

% Constantes de Poisson (valores típicos)
nu_fibra = 0.22;


% Propriedades dos materiais
materiais(1).nome = 'Fibra de Vidro';
materiais(1).rho = 2540;             % kg/m³
materiais(1).E = 72.4e9;              % Pa
materiais(1).nu = nu_fibra;
materiais(1).alpha = 25; % Coeficiente de atenuação estimado para Fibra de Vidro em dB/m (para 5MHz)

materiais(2).nome = 'Resina Epóxi';
materiais(2).rho = 1250;             % kg/m³
materiais(2).E = 3.5e9;              % Pa
materiais(2).alpha = 40; % Coeficiente de atenuação estimado para Resina Epóxi em dB/m (para 5MHz)

% Propriedades do Ar
rho_ar = 1.2;      % kg/m³
v_ar = 343;        % m/s
Z_ar = rho_ar * v_ar;  

% Parâmetros do Transdutor
fc = 5e6;           % Frequência central (5 MHz)

%% Perguntas ao Usuário
num_camadas = input('Número de camadas: ');
tipo = input('Escolha o tipo de material (1-Fibra de Vidro, 2-Resina Epóxi, 3-Compósito): ');

if tipo ~= 3
    espessuras = zeros(1, num_camadas);
    for i = 1:num_camadas
        espessura_cm = input(['Espessura da camada ', num2str(i), ' (cm): ']);
        espessuras(i) = espessura_cm / 100;  % Convertendo para metros
    end
end

%% Seção para Fibra de Vidro (Tipo 1)
if tipo == 1

    mat = materiais(1);
    % Cálculo da velocidade de propagação das ondas longitudinais (VL) para a fibra de vidro
    VL = sqrt((mat.E .* (1 - mat.nu)) ./ (mat.rho .* (1 + mat.nu) .* (1 - 2 .* mat.nu))); % Material Anisotrópico
    Z_mat = mat.rho * VL;  % Impedância da fibra
    R_ar = ((Z_mat - Z_ar) / (Z_mat + Z_ar))^2; %% Coeficiente de Reflexão(com o ar)

    tempos_acumulados = [];
    amplitudes = [];
    tempo_atual = 0;
    amplitude_atual = 1;

    % Calculo dos tempos e amplitudes das reflexões em cada camada
    for i = 1:num_camadas
        % Calcula o tempo de propagação na camada
        tempo_ida = espessuras(i) ./ VL;
        tempo_atual = tempo_atual + 2 * tempo_ida * 1e6;

        distancia = 2 * sum(espessuras(1:i)); % distância percorrida(ida e volta)

        % Calculo da atenuação (em dB) e a amplitude após a atenuação
        atenuacao_db = mat.alpha * distancia;
        fator_amplitude_atenuacao = 10^(-atenuacao_db / 20);
        amplitudes = [amplitudes, amplitude_atual * fator_amplitude_atenuacao];
        tempos_acumulados = [tempos_acumulados, tempo_atual];
    end

    % Amplitude final(tendo em conta o coeficiente de Reflexão)
    amplitude_refletida_final = amplitude_atual * sqrt(R_ar) * 10^(-(mat.alpha * sum(espessuras) * 2 / 20));

    figure;
    hold on;
    stem(tempos_acumulados, amplitudes, 'filled');
    stem(sum(espessuras) * 2 / VL * 1e6, amplitude_refletida_final, 'filled', 'r');
    xlabel('Tempo (µs)');
    ylabel('Amplitude');
    title(['Resposta impulsional - ', mat.nome]);
    legend('Reflexões internas (aproximadas)', 'Eco de fundo com R_{ar}');

%% Seção para Resina Epóxi (Tipo 2)
elseif tipo == 2

    mat = materiais(2);
    % Cálculo da velocidade de propagação para a resina de epóxido
    V = sqrt(mat.E ./ mat.rho); % Material Isotrópico
    Z_mat = mat.rho * V;  % Impedância da resina
    R_ar = ((Z_mat - Z_ar) / (Z_mat + Z_ar))^2; % coeficiente de Reflexão(com o ar)

    tempos_acumulados = [];
    amplitudes = [];
    tempo_atual = 0;
    amplitude_atual = 1;

    for i = 1:num_camadas
        tempo_ida = espessuras(i) ./ V;
        tempo_atual = tempo_atual + 2 * tempo_ida * 1e6;

        distancia = 2 * sum(espessuras(1:i));
        
        atenuacao_db = mat.alpha * distancia;
        fator_amplitude_atenuacao = 10^(-atenuacao_db / 20);
        amplitudes = [amplitudes, amplitude_atual * fator_amplitude_atenuacao];
        tempos_acumulados = [tempos_acumulados, tempo_atual];
    end

    % Amplitude final(tendo em conta o coeficiente de Reflexão)
    amplitude_refletida_final = amplitude_atual * sqrt(R_ar) * 10^(-(mat.alpha * sum(espessuras) * 2 / 20));

    figure;
    hold on;
    stem(tempos_acumulados, amplitudes, 'filled');
    stem(sum(espessuras) * 2 / V * 1e6, amplitude_refletida_final, 'filled', 'r');
    xlabel('Tempo (µs)');
    ylabel('Amplitude');
    title(['Resposta impulsional - ', mat.nome]);
    legend('Reflexões internas (aproximadas)', 'Transmissão Total (Fundo)');

%% Seção para Compósito (Tipo 3) 
elseif tipo == 3
    n_fibra_total = input('Número total de subcamadas de fibra: ');
    n_resina_total = input('Número total de subcamadas de resina: ');
    num_subcamadas = n_fibra_total + n_resina_total;
    if num_subcamadas ~= num_camadas
        error('O número total de subcamadas de fibra e resina deve ser igual ao número de camadas do compósito.');
    end

    espessuras_comp = zeros(1, num_camadas);
    tipos_camadas = zeros(1, num_camadas); % 1 para fibra, 2 para resina

    for i = 1:num_camadas
        tipo_camada = input(['Tipo da subcamada ', num2str(i), ' (1-Fibra, 2-Resina): ']);
        if tipo_camada ~= 1 && tipo_camada ~= 2
            error('Tipo de subcamada inválido.');
        end
        tipos_camadas(i) = tipo_camada;
        espessura_cm = input(['Espessura da subcamada ', num2str(i), ' (cm): ']);
        espessuras_comp(i) = espessura_cm / 100; % Convertendo para metros
    end

    % Calculo das propriedades do compósito a partir das frações volumétricas e propriedades dos materiais
    vf = n_fibra_total / num_camadas; % fração volumétrica, fibra
    vr = n_resina_total / num_camadas; % fração volumétrica, resina
    mat_fibra = materiais(1);
    mat_resina = materiais(2);

    tempos_acumulados = [];
    amplitudes = [];
    amplitude_atual = 1;
    tempo_atual = 0;

    % Calculo dos tempos e amplitudes das reflexões no compósito
    for i = 1:num_camadas
        espessura_camada = espessuras_comp(i);

        if tipos_camadas(i) == 1
            % velocidade longitudinal(para a fibra de vidro)
            VL_atual = sqrt((mat_fibra.E * (1 - mat_fibra.nu)) / (mat_fibra.rho * (1 + mat_fibra.nu) * (1 - 2 * mat_fibra.nu)));
            alpha_atual = mat_fibra.alpha;
        else
            % velocidade (para a resina de epóxido)
            VL_atual = sqrt(mat_resina.E / mat_resina.rho);
            alpha_atual = mat_resina.alpha;
        end

        tempo_ida = espessura_camada / VL_atual;
        tempo_atual = tempo_atual + 2 * tempo_ida * 1e6;

        distancia_total = 2 * sum(espessuras_comp(1:i));
        atenuacao_db_total = 0;

        for j = 1:i
            distancia_camada_j = 2 * espessuras_comp(j);
            % Atenuação se for fibra de vidro
            if tipos_camadas(j) == 1 
                atenuacao_db_total = atenuacao_db_total + mat_fibra.alpha * distancia_camada_j;
            % Atenuação se for resina de epóxido
            else
                atenuacao_db_total = atenuacao_db_total + mat_resina.alpha * distancia_camada_j;
            end
        end

        fator_amplitude_atenuacao_total = 10^(-atenuacao_db_total / 20);

        % Reflexão interna simulada (apenas pela atenuação)
        amplitude_refletida = amplitude_atual * fator_amplitude_atenuacao_total;
        amplitudes = [amplitudes, amplitude_refletida];
        tempos_acumulados = [tempos_acumulados, tempo_atual];
    end

    % Cálculo do eco de fundo (amplitude final) considerando a atenuação acumulada
    tempo_total = 0;
    for j = 1:num_camadas
        if tipos_camadas(j) == 1
            VL_atual = sqrt((mat_fibra.E * (1 - mat_fibra.nu)) / ...
                (mat_fibra.rho * (1 + mat_fibra.nu) * (1 - 2 * mat_fibra.nu)));
        else
            VL_atual = sqrt(mat_resina.E / mat_resina.rho);
        end
        tempo_total = tempo_total + 2 * espessuras_comp(j) / VL_atual;
    end
    tempo_total = tempo_total * 1e6;

    % Cálculo da atenuação total para o eco de fundo
    atenuacao_db_fundo = 0;
    for j = 1:num_camadas
        distancia_camada = 2 * espessuras_comp(j);
        if tipos_camadas(j) == 1
            atenuacao_db_fundo = atenuacao_db_fundo + mat_fibra.alpha * distancia_camada ;
        else
            atenuacao_db_fundo = atenuacao_db_fundo + mat_resina.alpha * distancia_camada;
        end
    end
    fator_amplitude_atenuacao_fundo = 10^(-atenuacao_db_fundo / 20);

    % Cálculo da impedância do compósito (média ponderada)
    % Z = rho * V
    Z_fibra = mat_fibra.rho * sqrt((mat_fibra.E * (1 - mat_fibra.nu)) / (mat_fibra.rho * (1 + mat_fibra.nu) * (1 - 2 * mat_fibra.nu)));
    Z_resina = mat_resina.rho * sqrt(mat_resina.E / mat_resina.rho);
    Z_comp = vf * Z_fibra + vr * Z_resina;

    % Coeficiente de reflexão com o ar
    R_ar = ((Z_comp - Z_ar) / (Z_comp + Z_ar))^2;

    % Amplitude final do eco de fundo considerando R_ar
    amplitude_fundo = amplitude_atual * fator_amplitude_atenuacao_fundo * sqrt(R_ar);

    % Plotagem
    figure;
    hold on;
    stem(tempos_acumulados, amplitudes, 'filled');
    stem(tempo_total, amplitude_fundo, 'filled', 'r');
    xlabel('Tempo (µs)');
    ylabel('Amplitude');
    title(['Resposta impulsional - Compósito (com coef. de reflexão com o ar)']);
    legend('Reflexões internas (aproximadas)', 'Eco de fundo com R_{ar}');
end
