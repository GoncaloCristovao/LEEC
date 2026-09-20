% Dificuldades:

%  Sobreposição de Ecos: Se as camadas forem muito finas, os ecos podem se 
% sobrepor no tempo, tornando a identificação dos picos individuais e seus 
% tempos mais difícil.

%  Unicidade da Solução: Pode haver múltiplas combinações de materiais e 
% espessuras que resultam em um padrão de reflexão semelhante.

%% Decifrar Camadas com Funções por Material
clc; clear; close all;

% --- Dados Observados ---
tempo_observado_us = [3.50593773143253	15.4582238247765	18.9641615562090];
sinal_reflexao_observado = [0.944060876285923	0.860993752184601	0.812830516164099];

% --- Converter Tempos para Segundos ---
tempo_observado = tempo_observado_us * 1e-6;
num_picos = length(tempo_observado);

% --- Propriedades dos Materiais (Fixas para Decifração) ---
materiais(1).nome = 'Fibra de Vidro';
materiais(1).VL = 5704.9;
materiais(1).alpha = 25;
materiais(1).Z = materiais(1).VL * 2540;
materiais(2).nome = 'Resina Epóxi';
materiais(2).VL = 1673.3;
materiais(2).alpha = 40;
materiais(2).Z = materiais(2).VL * 1250;

Z_ar = 343 * 1.2;
calcular_R = @(Z1, Z2) ((Z2 - Z1) / (Z2 + Z1))^2;
dB2neper = @(alpha_db) alpha_db / (20 * log10(exp(1)));
impedancias_previas = Z_ar; 
amplitude_inicial = 1;
tempo_inicial = 0;

% --- Funções de Cálculo da Espessura ---
calcular_espessura_fibra = @(delta_t) delta_t * materiais(1).VL / 2;
calcular_espessura_resina = @(delta_t) delta_t * materiais(2).VL / 2;

% --- Funções de Cálculo do Erro de Amplitude ---
calcular_erro_amplitude_fibra = @(esp, amp_obs, amp_prev_ref, Z_prev, Z_atual) ...
    abs(amp_prev_ref * sqrt(calcular_R(Z_prev, Z_atual)) * exp(-(dB2neper(materiais(1).alpha) * esp / 100)) - amp_obs);
calcular_erro_amplitude_resina = @(esp, amp_obs, amp_prev_ref, Z_prev, Z_atual) ...
    abs(amp_prev_ref * sqrt(calcular_R(Z_prev, Z_atual)) * exp(-(dB2neper(materiais(2).alpha) * esp / 100)) - amp_obs);

% --- Lógica Principal de Decifração ---
for i = 1:num_picos
    tempo_pico = tempo_observado(i);
    amplitude_pico_obs = sinal_reflexao_observado(i);
    delta_tempo = tempo_pico - tempo_inicial;
    melhor_erro = Inf;
    melhor_mat_idx = -1;
    melhor_esp = NaN;

    % Testar Fibra de Vidro como a camada atual
    esp_fibra = calcular_espessura_fibra(delta_tempo);
    if esp_fibra >= 0
        Z_atual_fibra = materiais(1).Z;
        erro_fibra = calcular_erro_amplitude_fibra(esp_fibra * 100, amplitude_pico_obs, amplitude_inicial, impedancias_previas, Z_atual_fibra);
        if erro_fibra < melhor_erro
            melhor_erro = erro_fibra;
            melhor_mat_idx = 1;
            melhor_esp = esp_fibra * 100;
        end
    end

    % Testar Resina Epóxi como a camada atual
    esp_resina = calcular_espessura_resina(delta_tempo);
    if esp_resina >= 0
        Z_atual_resina = materiais(2).Z;
        erro_resina = calcular_erro_amplitude_resina(esp_resina * 100, amplitude_pico_obs, amplitude_inicial, impedancias_previas, Z_atual_resina);
        if erro_resina < melhor_erro
            melhor_erro = erro_resina;
            melhor_mat_idx = 2;
            melhor_esp = esp_resina * 100;
        end
    end

    if melhor_mat_idx ~= -1
        material_decifrado = materiais(melhor_mat_idx);
        camadas_decifradas(i).material = material_decifrado.nome;
        camadas_decifradas(i).material_prop = material_decifrado;
        camadas_decifradas(i).espessura = melhor_esp;
        fprintf('--- Camada %d ---\n', i);
        fprintf('Tempo Pico: %.4f us\n', tempo_observado_us(i));
        fprintf('Material Estimado: %s\n', material_decifrado.nome);
        fprintf('Espessura Estimada: %.2f cm\n', melhor_esp);
        fprintf('Erro de Amplitude: %.6f\n\n', melhor_erro);
        impedancias_previas = material_decifrado.Z; % A impedância da camada decifrada torna-se a referência para a próxima interface
        amplitude_inicial = amplitude_pico_obs;
        tempo_inicial = tempo_pico;
    else
        fprintf('Não foi possível identificar a camada correspondente ao pico %d.\n', i);
    end
end



 
