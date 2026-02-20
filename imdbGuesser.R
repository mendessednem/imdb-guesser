# 0) Ficheiros
FILE_MOVIES <- "imdb(MOVIES).csv"
FILE_SERIES <- "imdb(SERIES).csv"
FILE_HIST   <- "historico_imdb.csv"
FILE_RANK   <- "ranking_jogadores.csv"

# 2) Escolher modalidade (carregar datasets)
carregar_datasets <- function() {
  filmes <- read.csv(FILE_MOVIES, sep = ";", header = TRUE, stringsAsFactors = FALSE)
  series <- read.csv(FILE_SERIES, sep = ";", header = TRUE, stringsAsFactors = FALSE)
  
  dataset_filmes <- data.frame(
    tipo = "Filme",
    titulo = as.character(filmes$movie_name_),
    ano = as.character(filmes$Year),
    rating = as.numeric(filmes$RATING)
  )
  
  dataset_series <- data.frame(
    tipo = "Série",
    titulo = as.character(series$series_name),
    ano = as.character(series$Year),
    rating = as.numeric(series$rating)
  )
  
  dataset_filmes <- dataset_filmes[!is.na(dataset_filmes$rating) & dataset_filmes$rating >= 0 & dataset_filmes$rating <= 10, ]
  dataset_series <- dataset_series[!is.na(dataset_series$rating) & dataset_series$rating >= 0 & dataset_series$rating <= 10, ]
  
  rbind(dataset_filmes, dataset_series)
}

# 3) Jogar (histórico + jogo)
linha_historico <- function(modalidade, ronda, tipo, titulo, ano, real, p1, p2, err1, err2, vencedor) {
  data.frame(
    data_hora = as.character(Sys.time()),
    modalidade = modalidade,
    ronda = ronda,
    tipo = tipo,
    titulo = titulo,
    ano = ano,
    rating_real = real,
    palpite_j1 = p1,
    palpite_j2 = p2,
    erro_j1 = err1,
    erro_j2 = err2,
    vencedor_ronda = vencedor
  )
}

guardar_historico <- function(linha) {
  if (file.exists(FILE_HIST)) {
    write.table(linha, FILE_HIST, sep = ",", col.names = FALSE,
                row.names = FALSE, append = TRUE)
  } else {
    write.table(linha, FILE_HIST, sep = ",", col.names = TRUE,
                row.names = FALSE)
  }
}

jogar_partida <- function(j1, j2, n_rondas, dataset, modalidade) {
  if (modalidade == "Filmes") dataset_modalidade <- dataset[dataset$tipo == "Filme", ]
  else if (modalidade == "Séries") dataset_modalidade <- dataset[dataset$tipo == "Série", ]
  else dataset_modalidade <- dataset
  
  pontos <- c()
  erros <- c()
  
  if (j1 != "") {
    pontos[j1] <- 0
    erros[j1] <- 0
  }
  if (j2 != "") {
    pontos[j2] <- 0
    erros[j2] <- 0
  }
  rondas_jogadas <- 0
  
  print("Adivinha o IMDb!")
  print(paste("Jogadores:", j1, "vs", j2))
  print(paste("Modalidade:", modalidade, "| Rondas:", n_rondas))
  amostra <- sample(1:nrow(dataset_modalidade), n_rondas, replace = FALSE)
  
  while (rondas_jogadas < n_rondas) {
    rondas_jogadas <- rondas_jogadas + 1
    i <- amostra[rondas_jogadas]
    
    titulo <- dataset_modalidade$titulo[i]
    ano <- dataset_modalidade$ano[i]
    rating <- dataset_modalidade$rating[i]
    tipo <- dataset_modalidade$tipo[i]
    
    print(paste("Ronda", rondas_jogadas, "de", n_rondas))
    print(paste("Tipo:", tipo, "| Título:", titulo, "| Ano:", ano))
    print("Palpite (0-10) ou 'sair':")
    
    if (rondas_jogadas %% 2 == 1) {
      j1_turn <- readline(paste(j1, "-> "))
      j2_turn <- readline(paste(j2, "-> "))
    } else {
      j2_turn <- readline(paste(j2, "-> "))
      j1_turn <- readline(paste(j1, "-> "))
    }
    
    if (tolower(j1_turn) == "sair" || tolower(j2_turn) == "sair") {
      print("Um jogador saiu. A sessão termina.")
      rondas_jogadas <- rondas_jogadas - 1
      break
    }
    
    p1 <- as.numeric(j1_turn)
    p2 <- as.numeric(j2_turn)
    
    if (is.na(p1) || is.na(p2) || p1 < 0 || p1 > 10 || p2 < 0 || p2 > 10) {
      print("Valor inválido. Ronda repetida.")
      rondas_jogadas <- rondas_jogadas - 1
      next
    }
    
    e1 <- abs(rating - p1)
    e2 <- abs(rating - p2)
    
    erros[j1] <- erros[j1] + e1
    erros[j2] <- erros[j2] + e2
    
    vencedor_ronda <- if (e1 < e2) j1 else if (e2 < e1) j2 else "empate"
    if (vencedor_ronda != "empate") pontos[vencedor_ronda] <- pontos[vencedor_ronda] + 1
    
    print(paste("IMDb real:", rating))
    if (vencedor_ronda == "empate") print("Empate!") else print(paste("Ponto para", vencedor_ronda))
    
    guardar_historico(linha_historico(modalidade, rondas_jogadas, tipo, titulo, ano,
                                      rating, p1, p2, e1, e2, vencedor_ronda))
  }
  
  print("Fim da sessão")
  
  if (rondas_jogadas > 0) {
    erro_m1 <- round(erros[j1] / rondas_jogadas, 3)
    erro_m2 <- round(erros[j2] / rondas_jogadas, 3)
  } else {
    erro_m1 <- NA; erro_m2 <- NA
  }
  
  print(paste(j1, "->", pontos[j1], "pontos | erro médio:", erro_m1))
  print(paste(j2, "->", pontos[j2], "pontos | erro médio:", erro_m2))
  
  if (pontos[j1] > pontos[j2]) vencedor <- j1
  else if (pontos[j2] > pontos[j1]) vencedor <- j2
  else vencedor <- "empate"
  
  print(paste("-> Vencedor:", vencedor ,"<-"))
  
  atualizar_ranking(j1, venceu = (vencedor == j1), pontos[j1], rondas_jogadas, erros[j1])
  atualizar_ranking(j2, venceu = (vencedor == j2), pontos[j2], rondas_jogadas, erros[j2])
}

# 4) Ver ranking (ler, atualizar, ordenar, mostrar e gráfico)
carregar_ranking <- function() {
  if (file.exists(FILE_RANK)) {
    read.csv(FILE_RANK, stringsAsFactors = FALSE)
  } else {
    data.frame(
      jogador = character(),
      jogos = integer(),
      vitorias = integer(),
      pontos = integer(),
      rondas = integer(),
      erro_total = numeric()
    )
  }
}

ordenar_ranking <- function(rk) {
  if (nrow(rk) <= 1) return(rk)
  for (i in 1:(nrow(rk) - 1)) {
    for (j in (i + 1):nrow(rk)) {
      if (rk$vitorias[j] > rk$vitorias[i]) {
        temp <- rk[i, ]; rk[i, ] <- rk[j, ]; rk[j, ] <- temp
      }
      if (rk$vitorias[j] == rk$vitorias[i] && rk$jogos[j] > rk$jogos[i]) {
        temp <- rk[i, ]; rk[i, ] <- rk[j, ]; rk[j, ] <- temp
      }
      if (rk$vitorias[j] == rk$vitorias[i] &&
          rk$jogos[j] == rk$jogos[i] &&
          rk$erro_medio[j] < rk$erro_medio[i]) {
        temp <- rk[i, ]; rk[i, ] <- rk[j, ]; rk[j, ] <- temp
      }
    }
  }
  rk
}

atualizar_ranking <- function(jogador, venceu, pontos_ganhos, rondas, erro_soma) {
  rk <- carregar_ranking()
  pos <- which(rk$jogador == jogador)
  
  if (length(pos) == 0) {
    rk <- rbind(rk, data.frame(
      jogador = jogador,
      jogos = 1,
      vitorias = if (venceu) 1 else 0,
      pontos = pontos_ganhos,
      rondas = rondas,
      erro_total = erro_soma
    ))
  } else {
    rk$jogos[pos] <- rk$jogos[pos] + 1
    if (venceu) rk$vitorias[pos] <- rk$vitorias[pos] + 1
    rk$pontos[pos] <- rk$pontos[pos] + pontos_ganhos
    rk$rondas[pos] <- rk$rondas[pos] + rondas
    rk$erro_total[pos] <- rk$erro_total[pos] + erro_soma
  }
  
  write.csv(rk, FILE_RANK, row.names = FALSE)
}

mostrar_ranking <- function() {
  rk <- carregar_ranking()
  if (nrow(rk) == 0) {
    print("Ainda não há jogadores no ranking.")
    return()
  }
  
  rk$erro_medio <- numeric(nrow(rk))
  for (i in 1:nrow(rk)) {
    if (rk$rondas[i] > 0) rk$erro_medio[i] <- rk$erro_total[i] / rk$rondas[i]
    else rk$erro_medio[i] <- NA
  }
  
  rk <- ordenar_ranking(rk)
  
  print("Ranking Global:")
  print(rk)
}

mostrar_grafico_jogos <- function() {
  rk <- read.csv(FILE_RANK, stringsAsFactors = FALSE)
  barplot(rk$vitorias,
          names.arg = rk$jogador,
          main = "Vitórias por jogador",
          ylab = "Número de vitórias",
          col  = "lightgray")
}

# 5) Ver Tops IMDb
mostrar_tops_imdb <- function(dataset) {
  print("Tops IMDb:")
  
  filmes <- dataset[dataset$tipo == "Filme", c("titulo", "ano", "rating")]
  series <- dataset[dataset$tipo == "Série", c("titulo", "ano", "rating")]
  
  if (nrow(filmes) > 0) {
    print("Top Filmes:")
    print(head(filmes, 10), row.names = FALSE)
  } else {
    print("Não há dados de filmes.")
  }
  
  if (nrow(series) > 0) {
    print("Top Séries:")
    print(head(series, 10), row.names = FALSE)
  } else {
    print("Não há dados de séries.")
  }
}

# 1) Configurar jogadores e 6) Sair (feitos diretamente no menu)
menu_principal <- function() {
  dataset <- carregar_datasets()
  jogador1 <- ""
  jogador2 <- ""
  modalidade <- "Misto"
  
  repeat {
    print("--------------------------------")
    print("        IMDb guesseR            ")
    print("--------------------------------")
    print("1) Configurar jogadores")
    print(paste("2) Escolher modalidade (atual:", modalidade, ")"))
    print("3) Jogar")
    print("4) Ver ranking")
    print("5) Ver Tops IMDb")
    print("6) Sair")
    
    opcao <- readline("Opção: ")
    
    if (opcao == "1") {
      jogador1 <- readline("Jogador 1: ")
      jogador2 <- readline("Jogador 2: ")
      
      if (jogador1 == "") jogador1 <- "Jogador1"
      if (jogador2 == "") jogador2 <- "Jogador2"
      
      jogador1 <- paste(toupper(substr(jogador1, 1, 1)), tolower(substr(jogador1, 2, nchar(jogador1))), sep = "")
      jogador2 <- paste(toupper(substr(jogador2, 1, 1)), tolower(substr(jogador2, 2, nchar(jogador2))), sep = "")
      
      print(paste("Jogadores:", jogador1, "vs", jogador2)) 
      
    } else if (opcao == "2") {
      print("1) Filmes  2) Séries  3) Misto")
      m <- as.integer(readline("Escolha da modalidade: "))
      if (m == 1) modalidade <- "Filmes"
      else if (m == 2) modalidade <- "Séries"
      else modalidade <- "Misto"
      
    } else if (opcao == "3") {
      if (jogador1 == "" || jogador2 == "") {
        print("Configura os jogadores primeiro.")
        next
      }
      n <- as.integer(readline("Quantas rondas? "))
      if (is.na(n) || n <= 0) n <- 5
      jogar_partida(jogador1, jogador2, n, dataset, modalidade)
      
    } else if (opcao == "4") {
      mostrar_ranking()
      mostrar_grafico_jogos()
      
    } else if (opcao == "5") {
      mostrar_tops_imdb(dataset)
      
    } else if (opcao == "6") {
      print("Até à próxima! I'll be back... for another round! (Terminator)")
      break
      
    } else {
      print("Opção inválida.")
    }
  }
}

menu_principal()


