extends Node

# Caminho onde o arquivo vai ser salvo no seu computador (pasta user:// do projeto)
var caminho_arquivo: String = "user://dados_simulacao.csv"

# Timer para controlar o intervalo de 10 segundos
var tempo_acumulado: float = 0.0
var intervalo_salvamento: float = 10.0

func _ready() -> void:
	# Quando o jogo inicia, criamos o arquivo e escrevemos o "cabeçalho" da tabela
	var arquivo = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	if arquivo:
		arquivo.store_line("Tempo_Segundos,Zezzits_Vivos,Velocidade_Media,Visao_Media")
		arquivo.close()
		print("Arquivo de dados criado em: ", ProjectSettings.globalize_path(caminho_arquivo))
	else:
		print("Erro ao criar o arquivo de dados!")

func _process(delta: float) -> void:
	tempo_acumulado += delta
	
	# Passou 10 segundos? Hora de coletar e salvar a linha na tabela!
	if tempo_acumulado >= intervalo_salvamento:
		tempo_acumulado = 0.0 # Reseta o relógio
		salvar_dados_frame()

func salvar_dados_frame() -> void:
	var todos_zes = get_tree().get_nodes_in_group("zezzits")
	var total_zes = todos_zes.size()
	
	var media_speed: float = 0.0
	var media_sight: float = 0.0
	
	if total_zes > 0:
		var soma_speed: float = 0.0
		var soma_sight: float = 0.0
		
		for ze in todos_zes:
			if is_instance_valid(ze):
				soma_speed += ze.speed
				soma_sight += ze.sight_range
				
		media_speed = soma_speed / total_zes
		media_sight = soma_sight / total_zes
	
	# Tempo total de jogo (arredondado para segundos inteiros)
	var tempo_atual = int(Time.get_ticks_msec() / 1000)
	
	# Abre o arquivo no modo APPEND (para continuar escrevendo embaixo sem apagar o que já tem)
	var arquivo = FileAccess.open(caminho_arquivo, FileAccess.READ_WRITE)
	if arquivo:
		# Vai para o final do arquivo para adicionar a nova linha
		arquivo.seek_end()
		
		# Monta a linha no formato CSV separada por vírgulas
		var linha = "%d,%d,%.2f,%.2f" % [tempo_atual, total_zes, media_speed, media_sight]
		arquivo.store_line(linha)
		arquivo.close()
		
		print("Dados salvos na tabela no tempo: ", tempo_atual, "s")
	else:
		print("Erro ao abrir o arquivo para escrita!")
