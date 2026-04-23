#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
  // TODO: Implement this function.
  const unsigned int COL_SIZE = 20;
  const unsigned int ROW_SIZE = 18;

  game_t *g = malloc(sizeof(game_t));
  snake_t *s = malloc(1 * sizeof(snake_t));

  // fill in the snake_t struct of the first and only snake
  s->tail_row = 2;
  s->tail_col = 2;
  s->head_row = 2;
  s->head_col = 4;
  s->live = true;

  // fill in the game_t struct
  g->num_rows = ROW_SIZE;
  g->num_snakes = 1;
  g->snakes = s;

  // initialise the board
  g->board = malloc(ROW_SIZE * sizeof(char *));
  for (int i = 0; i < ROW_SIZE; ++i) {
    g->board[i] = malloc((COL_SIZE + 2) * sizeof(char));
  }

  // create the top and bottom walls
  for (int j = 0; j < COL_SIZE; ++j) {
    g->board[0][j] = '#';
    g->board[ROW_SIZE - 1][j] = '#';
  }

  // create the left and right walls
  for (int i = 1; i < ROW_SIZE - 1; ++i) {
    g->board[i][0] = '#';
    g->board[i][COL_SIZE - 1] = '#';
    for (int j = 1; j < COL_SIZE - 1; ++j) {
      g->board[i][j] = ' ';
    }
  }

  // fill in the new line character for each row
  for (int i = 0; i < ROW_SIZE; ++i) {
    g->board[i][COL_SIZE] = '\n';
    g->board[i][COL_SIZE + 1] = 0;
  }

  // print the fruit
  g->board[2][9] = '*';

  // print the snake
  g->board[2][2] = 'd';
  g->board[2][3] = '>';
  g->board[2][4] = 'D';

  return g;
}

/* Task 2 */
void free_game(game_t *game) {
  // TODO: Implement this function.
  for (int i = 0; i < game->num_rows; ++i) {
    free(game->board[i]);
  }
  free(game->board);
  free(game->snakes);
  free(game);

  return;
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  // TODO: Implement this function.
  for (int i = 0; i < game->num_rows; ++i) {
    for (int j = 0; game->board[i][j] != '\0' && game->board[i][j] != '\n'; ++j) {
      fprintf(fp, "%c", game->board[i][j]);
    }
    fprintf(fp, "%c", '\n');
  }

  return;
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { 
  return game->board[row][col]; 
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' || c == 'd') {
    return true;
  }

  return false;
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x') {
    return true;
  }

  return false;
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  if (is_tail(c) || is_head(c)) {
    return true;
  }
  if (c == '^' || c == '<' || c == 'v' || c == '>') {
    return true;
  }

  return false;
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  switch(c) {
    case '^': return 'w';
    case '<': return 'a';
    case 'v': return 's';
    case '>': return 'd';
  }

  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  switch(c) {
    case 'W': return '^';
    case 'A': return '<';
    case 'S': return 'v';
    case 'D': return '>';
  }

  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  }

  if (c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }

  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  }

  if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int head_row = game->snakes[snum].head_row;
  unsigned int head_col = game->snakes[snum].head_col;
  char head_char = get_board_at(game, head_row, head_col);
  unsigned int next_row = get_next_row(head_row, head_char);
  unsigned int next_col = get_next_col(head_col, head_char);

  return get_board_at(game, next_row, next_col);
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int head_row = game->snakes[snum].head_row;
  unsigned int head_col = game->snakes[snum].head_col;
  char head_char = get_board_at(game, head_row, head_col);
  unsigned int next_row = get_next_row(head_row, head_char);
  unsigned int next_col = get_next_col(head_col, head_char);

  set_board_at(game, next_row, next_col, head_char);
  set_board_at(game, head_row, head_col, head_to_body(head_char));

  game->snakes[snum].head_row = next_row;
  game->snakes[snum].head_col = next_col;

  return;
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int tail_row = game->snakes[snum].tail_row;
  unsigned int tail_col = game->snakes[snum].tail_col;
  char tail_char = get_board_at(game, tail_row, tail_col);
  unsigned int next_row = get_next_row(tail_row, tail_char);
  unsigned int next_col = get_next_col(tail_col, tail_char);
  char next_char = get_board_at(game, next_row, next_col);

  set_board_at(game, tail_row, tail_col, ' ');
  set_board_at(game, next_row, next_col, body_to_tail(next_char));

  game->snakes[snum].tail_row = next_row;
  game->snakes[snum].tail_col = next_col;

  return;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  // TODO: Implement this function.
  for (unsigned int i = 0; i < game->num_snakes; ++i) {
    unsigned int head_row = game->snakes[i].head_row;
    unsigned int head_col = game->snakes[i].head_col;
    char head_char = get_board_at(game, head_row, head_col);
    unsigned int next_row = get_next_row(head_row, head_char);
    unsigned int next_col = get_next_col(head_col, head_char);
    char next_char = get_board_at(game, next_row, next_col);

    if (next_char == '#' || is_snake(next_char)) { // crashing
      set_board_at(game, head_row, head_col, 'x');
      game->snakes[i].live = false;
    } else if (next_char == '*') { // eating food
      update_head(game, i);
      add_food(game);
    } else {
      update_head(game, i);
      update_tail(game, i);
    }    
  }

  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  // TODO: Implement this function.
  const int MAX_COL = 100010;
  char buf[MAX_COL];
  unsigned int slen;

  if(fgets(buf, MAX_COL, fp)) {
    char *eol = strchr(buf, '\n');
    slen = eol - buf;
  } else {
    return NULL;
  }

  char * str = malloc((slen + 2) * sizeof(char));
  strcpy(str, buf); // str contains both '\n' and '\0'

  return str;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  // TODO: Implement this function.
  const unsigned int MAX_ROW = 100000;
  char **strptr = malloc(MAX_ROW * sizeof(char *));
  char * s;
  int cnt = 0;

  game_t *g = malloc(sizeof(game_t));
  
  while (s = read_line(fp)) {
    strptr[cnt++] = s;
  }

  g->num_rows = cnt;
  g->board = realloc(strptr, cnt * sizeof(char *));
  g->num_snakes = 0;
  g->snakes = NULL;

  return g;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  unsigned int cur_row = game->snakes[snum].tail_row;
  unsigned int cur_col = game->snakes[snum].tail_col;
  char cur_char = get_board_at(game, cur_row, cur_col);
  
  while (!is_head(cur_char)) {
    cur_row = get_next_row(cur_row, cur_char);
    cur_col = get_next_col(cur_col, cur_char);
    cur_char = get_board_at(game, cur_row, cur_col);
  }

  game->snakes[snum].head_row = cur_row;
  game->snakes[snum].head_col = cur_col;
  if (cur_char != 'x') {
    game->snakes[snum].live = true; 
  } else {
    game->snakes[snum].live = false; 
  }

  return;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  // TODO: Implement this function.
  unsigned const int MAX_SNUM = 1000;
  game->snakes = malloc(MAX_SNUM * sizeof(snake_t));
  unsigned int s_cnt = 0;

  for (unsigned int r = 0; r < game->num_rows; ++r) {
    for (unsigned int c = 0; game->board[r][c] != '\n'; ++c) {
      if (is_tail(game->board[r][c])) {
        game->snakes[s_cnt].tail_row = r;
        game->snakes[s_cnt].tail_col = c;
        find_head(game, s_cnt++);
      }
    }
  }

  game->snakes = realloc(game->snakes, s_cnt * sizeof(snake_t));
  game->num_snakes = s_cnt;

  return game;
}

//gdb --args ./snake -i tests/17-wide-in.snk -o tests/17-wide-out.snk
