# IMDb guesseR 🎬

IMDb guesseR is a Player vs Player game where two players compete to guess, as accurately as possible, the IMDb rating of movies or TV series.

---

## 🎮 How to Play

1. Each player enters their name.
2. Choose the game mode — Movies, Series, or Mixed.
3. Define the number of rounds.
4. In each round, a random title is displayed and both players attempt to guess its IMDb rating.
5. The player whose guess is closest to the real rating wins the round.
6. At the end of the match, the game displays the winner, the average error of each player, and the updated ranking.

---

## 📋 Main Menu

The game is controlled through a menu with six options:

### 1 - Configure Players
Enter or change the names of the two players.

### 2 - Choose Mode
Define whether the game will include only Movies, only Series, or Mixed mode.

**Main function:** `carregar_datasets()`

### 3 - Play
Starts a match with multiple rounds, error calculation, and result recording.

**Functions involved:**  
`jogar_partida()`  
`linha_historico()`  
`guardar_historico()`  
`atualizar_ranking()`

### 4 - View Ranking
Displays the global ranking table including number of games, wins, points, and average error.

**Functions involved:**  
`mostrar_ranking()`  
`ordenar_ranking()`  
`mostrar_grafico_jogos()`

### 5 - View IMDb Top 10
Displays the top 10 highest-rated movies and top 10 highest-rated series.

**Function:** `mostrar_tops_imdb()`

### 6 - Exit
Terminates the program with a closing message.

---

## 📊 Data Source

The data used in this project was obtained from the following GitHub repository:

https://github.com/WittmannF/imdb-tv-ratings/tree/master/data

The original CSV files (movies and series) were exported and reduced in size to simplify implementation and improve performance.

---

## 📁 File Structure

During gameplay, the following files are automatically created and updated:

### `imdb(MOVIES).csv`
List of movies with their IMDb ratings and release year.  
**Loaded by:** `carregar_datasets()`

### `imdb(SERIES).csv`
List of series with their IMDb ratings and year range.  
**Loaded by:** `carregar_datasets()`

### `historico_imdb.csv`
Stores all played rounds (title, year, guesses, and winner).  
**Functions:** `linha_historico()`, `guardar_historico()`

### `ranking_jogadores.csv`
Stores global player statistics (games played, wins, points, and average error).  
**Functions:** `carregar_ranking()`, `ordenar_ranking()`

---

## 🛠 Technologies Used

- R
- CSV data processing
- Console-based interaction
- Basic statistical tracking

---

## 🎯 Project Purpose

IMDb guesseR was developed as an interactive programming project combining logic, file handling, and real-world data.  
It transforms IMDb ratings into a competitive guessing game while tracking long-term player performance.
