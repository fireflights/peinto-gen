/* @pjs font="./assets/fonts/Oswald-Light.ttf, ./assets/fonts/Oswald-Regular.ttf, ./assets/fonts/Oxygen-Regular.ttf"; */

//////////////////////
// Global variables //
//////////////////////

int[][] data, query;
int data_rows, data_columns, query_rows, query_columns, cur_score, high_score;
float start_pos_x, start_pos_y, box_width, box_height, box_length, min_data, max_data, button_angle, time, start_time, cur_time, settings_time, start_time_ans;
Cell[][] grid;
String mode;
PFont header_font, text_font, text_font_2;
PImage sample_heat_map, sample_pattern, sample_scale;
boolean is_game_setup, is_timer_running, is_game_over, is_dim_error, is_ans, is_correct_ans;

///////////////
///////////////
//// Setup ////
///////////////
///////////////

void setup() {
  size(1200, 800, P2D);

  // Load fonts //
  header_font = createFont("./assets/fonts/Oswald-Regular.ttf", 48);
  text_font = createFont("./assets/fonts/Oxygen-Regular.ttf", 30);
  text_font_2 = createFont("./assets/fonts/Oswald-Light.ttf", 30);

  // Load images //
  sample_heat_map = loadImage("./assets/img/sample_heat_map.png");
  sample_pattern = loadImage("./assets/img/sample_pattern.png");
  sample_scale = loadImage("./assets/img/sample_scale.png");

  // Initialize start screen grid //
  float start_screen_width = width/4;
  float start_screen_height = height/4;
  grid = new Cell[4][2];
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j] = new Cell(start_screen_width * i, start_screen_height * j, start_screen_width, start_screen_height, i + j);
    }
  }

  // Initialize settings //
  mode = "start";
  start_pos_x = 50;
  start_pos_y = 150;

  data_rows = 3;
  data_columns = 3;
  min_data = -2
  max_data = 2
  query_rows = 2;
  query_columns = 2;
  time = settings_time = 61;

  cur_score = 0;
  high_score = 0;

  button_angle = 0;

  is_game_setup = true;
  is_game_over = false;
  is_timer_running = false;
  is_dim_error = true;
  is_ans = false;
}

///////////////////
///////////////////
//// End Setup ////
///////////////////
///////////////////

////////////////////
////////////////////
//// Start Draw ////
////////////////////
////////////////////

void draw() {
  background(255);
  if(mode == "start") {
    start_screen(grid);
  }
  else if(mode == "settings") {
    settings_screen();
  }
  else if(mode == "instructions") {
    instructions_screen();
  }
  else if(mode == "game") {
    game_screen();
  }
}

////////////////////////
// Begin start screen //
////////////////////////

void start_screen(Cell[][] grid) {
  pushMatrix();
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j].oscillate();
      grid[i][j].display("green");
    }
  }
  translate(0, height / 2);
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j].oscillate();
      grid[i][j].display("red");
    }
  }
  popMatrix();

  pushMatrix();
  translate(300, 200);
  stroke(255);
  strokeWeight(3);
  fill(255);
  rect(0, 0, 600, 300);
  textFont(header_font);
  textSize(145);
  textAlign(CENTER, CENTER);
  fill(0);
  text("HEAT", 300, 150);

  button_angle += 0.01

  translate(0, 300);
  // stroke(127.5 + 127.5 * sin(button_angle - 2 * PI / 3));
  // noFill();
  stroke(0);
  fill(255);
  rect(0, 0, 200, 100);

  // fill(127.5 + 127.5 * sin(button_angle - 2 * PI / 3));
  fill(0);
  textFont(text_font_2);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("Start Game", 100, 50);

  translate(200, 0);
  // stroke(127.5 + 127.5 * sin(button_angle - 7 * PI / 12));
  // noFill();
  stroke(0);
  fill(255);
  rect(0, 0, 200, 100);

  // fill(127.5 + 127.5 * sin(button_angle - 7 * PI / 12));
  fill(0);
  textAlign(CENTER, CENTER);
  text("Settings", 100, 50);

  translate(200, 0);
  // stroke(127.5 + 127.5 * sin(button_angle - PI / 2));
  // noFill();
  stroke(0);
  fill(255);
  rect(0, 0, 200, 100);

  // fill(127.5 + 127.5 * sin(button_angle - PI / 2));
  fill(0);
  textAlign(CENTER, CENTER);
  text("Instructions", 100, 50);
  popMatrix();

  popMatrix();
}

class Cell {
  public Cell(float tempX, float tempY, float tempW, float tempH, float tempAngle) {
    this.x = tempX;
    this.y = tempY;
    this.w = tempW;
    this.h = tempH;
    this.angle = tempAngle;
  }

  public void oscillate() {
    this.angle += 0.005;
  }

  public void display(String color) {
    noStroke();
    if(color == "red") {
      fill(175.5 + 63.5 * sin(this.angle), 123 + 123 * sin(this.angle), 128 + 127 * sin(this.angle));
    }
    else{
      fill(140.5 + 98.5 * sin(this.angle), 165.5 + 80.5 * sin(this.angle), 174.5 + 80.5 * sin(this.angle));
    }
    rect(this.x, this.y, this.w, this.h);
  }
}

void mouse_pressed_start() {
  if(mouseX > 300 && mouseX < 500 && mouseY > 500 && mouseY < 600) {
    reset_game();
    mode = "game";
  }
  if(mouseX > 500 && mouseX < 700 && mouseY > 500 && mouseY < 600) {
    reset_game();
    mode = "settings";
  }
  if(mouseX > 700 && mouseX < 900 && mouseY > 500 && mouseY < 600) {
    mode = "instructions";
  }
}

//////////////////////
// End start screen //
//////////////////////

///////////////////////////
// Begin settings screen //
///////////////////////////

void settings_screen() {
  pushMatrix();
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j].oscillate();
      grid[i][j].display("green");
    }
  }
  translate(0, height / 2);
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j].oscillate();
      grid[i][j].display("red");
    }
  }
  popMatrix();

  pushMatrix();
  translate(150, 60);
  button_angle += 0.01
  stroke(127.5 + 127.5 * sin(button_angle - 2 * PI / 3));
  strokeWeight(3);
  noFill();
  rect(0, 0, 200, 80);

  fill(127.5 + 127.5 * sin(button_angle - 2 * PI / 3));
  textFont(text_font_2);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Settings", 100, 40);

  stroke(0);
  fill(255);
  rect(280, 10, 540, 50);
  textFont(text_font_2);
  textSize(25);
  textAlign(CENTER, TOP);
  fill(0);
  text("Note: Going to the settings screen resets your high score.", 550, 20);
  popMatrix();

  pushMatrix();
  translate(150, 140);
  fill(255);
  stroke(0);
  rect(0, 0, 900, 540);

  textFont(header_font);
  textSize(30);
  stroke(0);
  float box_size = (450 - 20) / 9;

  // Heat Map Size //

  fill(0);
  textAlign(LEFT, TOP);
  text("Heat Map Size", 10, 10);
  translate(10, 60);
  textFont(text_font);
  textSize(25);
  textAlign(CENTER, TOP);
  text("Rows", 215, 0);
  text("Columns", 215, 95);
  translate(0, 30);
  float a_heat_map_row_box, b_heat_map_row_box, c_heat_map_row_box, a_heat_map_row_text, b_heat_map_row_text, c_heat_map_row_text;
  float a_heat_map_col_box, b_heat_map_col_box, c_heat_map_col_box, a_heat_map_col_text, b_heat_map_col_text, c_heat_map_col_text;
  for(int i = 2; i < 11; i++) {
    if(i == data_rows) {
      a_heat_map_row_box = 0;
      b_heat_map_row_box = 0;
      c_heat_map_row_box = 0;
      a_heat_map_row_text = 255;
      b_heat_map_row_text = 255;
      c_heat_map_row_text = 255;
    }
    else {
      a_heat_map_row_box = 239;
      b_heat_map_row_box = 246;
      c_heat_map_row_box = 255;
      a_heat_map_row_text = 0;
      b_heat_map_row_text = 0;
      c_heat_map_row_text = 0;
    }
    if(i == data_columns) {
      a_heat_map_col_box = 0;
      b_heat_map_col_box = 0;
      c_heat_map_col_box = 0;
      a_heat_map_col_text = 255;
      b_heat_map_col_text = 255;
      c_heat_map_col_text = 255;
    }
    else {
      a_heat_map_col_box = 239;
      b_heat_map_col_box = 246;
      c_heat_map_col_box = 255;
      a_heat_map_col_text = 0;
      b_heat_map_col_text = 0;
      c_heat_map_col_text = 0;
    }
    fill(a_heat_map_row_box, b_heat_map_row_box, c_heat_map_row_box);
    rect((i - 2) * box_size, 0, box_size, box_size);
    fill(a_heat_map_col_box, b_heat_map_col_box, c_heat_map_col_box);
    rect((i - 2) * box_size, 95, box_size, box_size);
    textFont(text_font_2);
    textSize(25);
    textAlign(LEFT, TOP);
    fill(a_heat_map_row_text, b_heat_map_row_text, c_heat_map_row_text);
    text(i, (i - 2) * box_size + (box_size - textWidth(i)) / 2, (box_size - 28) / 2);
    fill(a_heat_map_col_text, b_heat_map_col_text, c_heat_map_col_text);
    text(i, (i - 2) * box_size + (box_size - textWidth(i)) / 2, 95 + (box_size - 28) / 2);
  }

  // Min and Max Values //

  translate(-10, 180);
  fill(0);
  rect(0, -0.5, 900, 1);
  textFont(header_font);
  textSize(30);
  text("Heat Map Values", 10, 10);
  translate(130, 60);
  textFont(text_font);
  textSize(25);
  textAlign(CENTER, TOP);
  text("Minimum", 95, 0);
  text("Maximum", 95, 95);
  translate(0, 30);
  float a_min_data_box, b_min_data_box, c_min_data_box, a_min_data_text, b_min_data_text, c_min_data_text;
  for(int i = -4; i < 0; i++) {
    if(i == min_data) {
      a_min_data_box = 0;
      b_min_data_box = 0;
      c_min_data_box = 0;
      a_min_data_text = 255;
      b_min_data_text = 255;
      c_min_data_text = 255;
    }
    else {
      a_min_data_box = 239;
      b_min_data_box = 246;
      c_min_data_box = 255;
      a_min_data_text = 0;
      b_min_data_text = 0;
      c_min_data_text = 0;
    }
    fill(a_min_data_box, b_min_data_box, c_min_data_box);
    rect((i + 4) * box_size, 0, box_size, box_size);
    textFont(text_font_2);
    textSize(25);
    fill(a_min_data_text, b_min_data_text, c_min_data_text);
    textAlign(LEFT, TOP);
    text(i, (i + 4) * box_size + (box_size - textWidth(i)) / 2, (box_size - 28) / 2);
  }
  float a_max_data_box, b_max_data_box, c_max_data_box, a_max_data_text, b_max_data_text, c_max_data_text;
  for(int i = 1; i < 5; i++) {
    if(i == max_data) {
      a_max_data_box = 0;
      b_max_data_box = 0;
      c_max_data_box = 0;
      a_max_data_text = 255;
      b_max_data_text = 255;
      c_max_data_text = 255;
    }
    else {
      a_max_data_box = 239;
      b_max_data_box = 246;
      c_max_data_box = 255;
      a_max_data_text = 0;
      b_max_data_text = 0;
      c_max_data_text = 0;
    }
    fill(a_max_data_box, b_max_data_box, c_max_data_box);
    rect((i - 1) * box_size, 95, box_size, box_size);
    textFont(text_font_2);
    textSize(25);
    fill(a_max_data_text, b_max_data_text, c_max_data_text);
    textAlign(LEFT, TOP);
    text(i, (i - 1) * box_size + (box_size - textWidth(i)) / 2, 95 + (box_size - 28) / 2);
  }

  // Query Matrix //

  translate(320, -360);
  fill(0);
  rect(-0.5, 0, 1, 540);
  textFont(header_font);
  textSize(30);
  textAlign(LEFT, TOP);
  text("Pattern Size", 10, 10);
  translate(105, 60);
  textFont(text_font);
  textSize(25);
  textAlign(CENTER, TOP);
  text("Rows", 120, 0);
  text("Columns", 120, 95);
  translate(0, 30);
  float a_query_row_box, b_query_row_box, c_query_row_box, a_query_row_text, b_query_row_text, c_query_row_text;
  float a_query_col_box, b_query_col_box, c_query_col_box, a_query_col_text, b_query_col_text, c_query_col_text;
  for(int i = 1; i < 6; i++) {
    if(i == query_rows) {
      a_query_row_box = 0;
      b_query_row_box = 0;
      c_query_row_box = 0;
      a_query_row_text = 255;
      b_query_row_text = 255;
      c_query_row_text = 255;
    }
    else {
      a_query_row_box = 239;
      b_query_row_box = 246;
      c_query_row_box = 255;
      a_query_row_text = 0;
      b_query_row_text = 0;
      c_query_row_text = 0;
    }
    if(i == query_columns) {
      a_query_col_box = 0;
      b_query_col_box = 0;
      c_query_col_box = 0;
      a_query_col_text = 255;
      b_query_col_text = 255;
      c_query_col_text = 255;
    }
    else {
      a_query_col_box = 239;
      b_query_col_box = 246;
      c_query_col_box = 255;
      a_query_col_text = 0;
      b_query_col_text = 0;
      c_query_col_text = 0;
    }
    fill(a_query_row_box, b_query_row_box, c_query_row_box);
    rect((i - 1) * box_size, 0, box_size, box_size);
    fill(a_query_col_box, b_query_col_box, c_query_col_box);
    rect((i - 1) * box_size, 95, box_size, box_size);
    textFont(text_font_2);
    textSize(25);
    fill(a_query_row_text, b_query_row_text, c_query_row_text);
    textAlign(LEFT, TOP);
    text(i, (i - 1) * box_size + (box_size - textWidth(i)) / 2, (box_size - 28) / 2);
    fill(a_query_col_text, b_query_col_text, c_query_col_text);
    text(i, (i - 1) * box_size + (box_size - textWidth(i)) / 2, 95 + (box_size - 28) / 2);
  }
  if(data_rows < 5) {
    for(int i = data_rows + 1; i < 6; i++) {
      stroke(0);
      line(i * box_size, 0, (i - 1) * box_size, box_size);
    }
  }
  if(data_columns < 5) {
    for(int i = data_columns + 1; i < 6; i++) {
      stroke(0);
      line(i * box_size, 95, (i - 1) * box_size, 95 + box_size);
    }
  }

  // Time //

  translate(-105, 180);
  fill(0);
  textFont(header_font);
  textSize(30);
  textAlign(LEFT, TOP);
  text("Time", 10, 10);
  translate(81, 95);
  textFont(text_font);
  textSize(25);
  textAlign(CENTER, TOP);
  text("Seconds", 144, 0);
  translate(0, 30);
  float a_time_box, b_time_box, c_time_box, a_time_text, b_time_text, c_time_text;
  for(int i = 1; i < 7; i++) {
    if(i * 30 + 1 == time) {
      a_time_box = 0;
      b_time_box = 0;
      c_time_box = 0;
      a_time_text = 255;
      b_time_text = 255;
      c_time_text = 255;
      settings_time = time;
    }
    else {
      a_time_box = 239;
      b_time_box = 246;
      c_time_box = 255;
      a_time_text = 0;
      b_time_text = 0;
      c_time_text = 0;
    }
    fill(a_time_box, b_time_box, c_time_box);
    rect((i - 1) * box_size, 0, box_size, box_size);
    textFont(text_font_2);
    textSize(25);
    fill(a_time_text, b_time_text, c_time_text);
    textAlign(LEFT, TOP);
    text(i * 30, (i - 1) * box_size + (box_size - textWidth(i * 30)) / 2, (box_size - 28) / 2);
  }

  translate(-531, -125);
  noFill();
  stroke(127.5 + 127.5 * sin(button_angle - PI / 4));
  rect(450, 270, 450, 60);
  textFont(text_font_2);
  textSize(45);
  fill(127.5 + 127.5 * sin(button_angle - PI / 4));
  text("Click here to play!", 675 - textWidth("Click here to play!") / 2, 271);

  noFill();
  stroke(127.5 + 127.5 * sin(button_angle - 3 * PI / 4));
  rect(0, 270, 450, 60);
  textFont(text_font_2);
  textSize(45);
  fill(127.5 + 127.5 * sin(button_angle - 3 * PI / 4));
  text("Back to main menu", 225 - textWidth("Back to main menu") / 2, 271);

  popMatrix();
}

void mouse_pressed_settings() {
  float box_size = 430 / 9;

  // Heat Map Size and Query Matrix Size//

  if(mouseY > 230 && mouseY < 230 + box_size) {
    for(int i = 0; i < 9; i++) {
      if(mouseX > 160 + i * box_size && mouseX < 160 + (i + 1) * box_size) {
        data_rows = i + 2;
        if(data_rows < query_rows) {
          query_rows = data_rows;
        }
        break;
      }
    }
    for(int i = 0; i < data_rows; i++) {
      if(mouseX > 705 + i * box_size && mouseX < 705 + (i + 1) * box_size) {
        query_rows = i + 1;
        break;
      }
    }
  }

  if(mouseY > 325 && mouseY < 325 + box_size) {
    for(int i = 0; i < 9; i++) {
      if(mouseX > 160 + i * box_size && mouseX < 160 + (i + 1) * box_size) {
        data_columns = i + 2;
        if(data_columns < query_columns) {
          query_columns = data_columns;
        }
        break;
      }
    }
    for(int i = 0; i < data_columns; i++) {
      if(mouseX > 705 + i * box_size && mouseX < 705 + (i + 1) * box_size) {
        query_columns = i + 1;
        break;
      }
    }
  }

  // Heat Map Max and Min Values

  if(mouseY > 500 && mouseY < 500 + box_size) {
    for(int i = 0; i < 4; i++) {
      if(mouseX > 280 + i * box_size && mouseX < 280 + (i + 1) * box_size) {
        min_data = i - 4;
        break;
      }
    }
  }

  if(mouseY > 595 && mouseY < 595 + box_size) {
    for(int i = 0; i < 4; i++) {
      if(mouseX > 280 + i * box_size && mouseX < 280 + (i + 1) * box_size) {
        max_data = i + 1;
        break;
      }
    }
  }

  // Timer

  if(mouseY > 535 && mouseY < 535 + box_size) {
    for(int i = 0; i < 6; i++) {
      if(mouseX > 681 + i * box_size && mouseX < 681 + (i + 1) * box_size) {
        time = (i + 1) * 30 + 1;
        break;
      }
    }
  }

  // Other buttons

  if(mouseY > 680 && mouseY < 740) {
    if(mouseX > 600 && mouseX < 1050) {
      high_score = 0;
      reset_game();
      mode = "game";
    }
    if(mouseX > 150 && mouseX < 600) {
      mode = "start";
    }
  }
}

boolean is_dim_valid() {
  if(data_columns >= query_columns && data_rows >= query_rows) {
    return true;
  }
  else {
    return false;
  }
}

/////////////////////////
// End settings screen //
/////////////////////////

///////////////////////////////
// Begin instructions screen //
///////////////////////////////

void instructions_screen() {
  pushMatrix();
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j].oscillate();
      grid[i][j].display("green");
    }
  }
  translate(0, height / 2);
  for(int i = 0; i < grid.length; i++) {
    for(int j = 0; j < grid[0].length; j++) {
      grid[i][j].oscillate();
      grid[i][j].display("red");
    }
  }
  popMatrix();

  pushMatrix();
  translate(150, 60);
  button_angle += 0.01
  stroke(127.5 + 127.5 * sin(button_angle - 2 * PI / 3));
  strokeWeight(3);
  noFill();
  rect(0, 0, 200, 80);

  fill(127.5 + 127.5 * sin(button_angle - 2 * PI / 3));
  textFont(text_font_2);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Instructions", 100, 40);
  popMatrix();

  pushMatrix();
  translate(150, 140);
  fill(255);
  stroke(0);
  rect(0, 0, 900, 540);

  fill(0);
  textAlign(LEFT, TOP);
  textFont(text_font);
  textSize(25);
  text("HEAT is a game designed to help you detect patterns in heat maps. Your goal is", 10, 10);
  text("to find as many patterns as you can in the heat maps provided.", 10, 45);
  translate(0, 6);
  text("In the example to the right, the", 10, 95);
  text("pattern is in the lower-left corner", 10, 130);
  text("(surrounded by the thick black", 10, 165);
  text("square). On the given scale,", 10, 200);
  text("white squares correspond to 0", 10, 235);
  text("and light red squares correspond", 10, 270);
  text("to 1.", 10, 305);
  translate(0, 4);
  text("You select a pattern by clicking the square on its upper-left corner. Be careful", 10, 360);
  text("not to randomly select patterns because you get a point deduction for every", 10, 395);
  text("incorrect selection.", 10, 430);
  text("We hope you enjoy the game!", 10, 481);
  translate(280, -45);
  image(sample_scale, 115, 120, 250, 25);
  image(sample_heat_map, 115, 150, 250, 250);
  image(sample_pattern, 392, 150, 200, 215);
  translate(-280, 35);

  translate(0, 540);
  noFill();
  stroke(127.5 + 127.5 * sin(button_angle - PI / 3));
  rect(0, 0, 900, 60);
  textFont(text_font_2);
  textSize(45);
  fill(127.5 + 127.5 * sin(button_angle - PI / 3));
  textAlign(CENTER, CENTER);
  text("Back to main menu", 600 - textWidth("Back to main menu") / 2, 28);
  popMatrix();
}

void mouse_pressed_instructions() {
  if(mouseX > 150 && mouseX < 1050 && mouseY > 680 && mouseY < 740) {
    high_score = 0;
    reset_game();
    mode = "start";
  }
}

/////////////////////////////
// End instructions screen //
/////////////////////////////

///////////////////////
// Begin game screen //
///////////////////////

void game_screen() {
  // Load data //
  if(is_game_setup) {
    setup_game();
  }

  draw_heat_map();

  draw_query_rect();

  draw_ui();

  draw_response();
}

void setup_game() {
  data = generate_data(data_rows, data_columns, min_data, max_data);

  // Create query based on data //
  query = generate_query(data, query_rows, query_columns);
  is_game_setup = false;
}

//////////////////////////////////
// Start Data-Related Functions //
//////////////////////////////////

int[][] generate_data(int rows, int columns, float min, float max){
  data = new int[rows][columns];
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < columns; j++){
      data[i][j] = round(random(min - 0.5, max + 0.5));
      // 0.5 subtracted and added to make the probabilities of getting all
      // integers in the interval equal //
    }
  }
  return data;
}

int[][] generate_query(int[][] data, int rows, int columns) {
    data_row_start = round(random(0.5, data.length - rows + 1.5));
    data_column_start = round(random(0.5, data[0].length - columns + 1.5));
    query = new int[rows][columns];
    for(int i = 0; i < rows; i++) {
      for(int j = 0; j < columns; j++) {
        query[i][j] = data[data_row_start + i - 1][data_column_start + j - 1];
      }
    }
    return query;
  }

////////////////////////////////
// End Data-Related Functions //
////////////////////////////////

void draw_heat_map() {

  draw_legend();

  int nrow, ncol;
  nrow = data.length;
  ncol = data[0].length;

  box_width = (width - 600) / ncol;
  box_height = (height - 200) / nrow;
  
  float init_x = start_pos_x - box_width;
  float init_y = start_pos_y - box_height;
  float cur_y = init_y;

  pushMatrix();

  // Draw borders.
  stroke(0);
  strokeWeight(5);
  noFill();
  rect(start_pos_x, start_pos_y, box_width * data_columns, box_height * data_rows);

  noStroke();

  init_x = start_pos_x - box_width;
  init_y = cur_y = start_pos_y - box_height;
  
  translate(init_x, init_y);
  
  for(int i = 0; i < data.length; i++) {
    float cur_x = init_x;
    translate(0, box_height);
    cur_y += box_height;

    pushMatrix();
    for(int j = 0; j < data[0].length; j++) {
      translate(box_width, 0);
      cur_x += box_width;
      float cur_data = data[i][j];
      float a, b, c, ratio;
      if (cur_data >= 0) { // up-regulated genes
        ratio = cur_data / max_data;
        a = (255 - 193) * (1 - ratio) + 193;
        b = (255 - 0) * (1 - ratio) + 0;
        c = (255 - 1) * (1 - ratio) + 1;
      }
      else {
        ratio = cur_data / min_data; // down-regulated genes
        a = (255 - 112) * (1 - ratio) + 112;
        b = (255 - 171) * (1 - ratio) + 171;
        c = (255 - 175) * (1 - ratio) + 175;
      }
      fill(a, b, c);
      rect(0, 0, box_width, box_height);
    }
    popMatrix();
  }
  popMatrix();
}

void draw_legend() {
  int num_colors = int(max_data - min_data) + 1;
  float legend_box_width = 500 / 9;
  float legend_box_height = legend_box_width / 2;

  pushMatrix();
  translate(100 + legend_box_width * (9 - num_colors) / 2, (150 - legend_box_height) / 2);
  noFill();
  strokeWeight(2);
  stroke(0);
  rect(0, 0, legend_box_width * num_colors, legend_box_height);

  noStroke();
  for(int i = min_data; i < 1; i++) {
    float ratio, a, b, c;
    ratio = i / min_data;
    a = (255 - 112) * (1 - ratio) + 112;
    b = (255 - 171) * (1 - ratio) + 171;
    c = (255 - 175) * (1 - ratio) + 175;
    fill(a, b, c);
    rect((i - min_data) * legend_box_width, 0, legend_box_width, legend_box_height);
  }
  int num_neg = -min_data;
  for(int i = 1; i < max_data + 1; i++) {
    float ratio, a, b, c;
    ratio = i / max_data;
    a = (255 - 193) * (1 - ratio) + 193;
    b = (255 - 0) * (1 - ratio) + 0;
    c = (255 - 1) * (1 - ratio) + 1;
    fill(a, b, c);
    rect((num_neg + i) * legend_box_width, 0, legend_box_width, legend_box_height);
  }

  textFont(text_font_2);
  textSize(legend_box_height * 0.9);
  textAlign(LEFT, TOP);
  fill(0);
  text("min", -textWidth("min") * 1.1, 0);
  fill(255);
  text(min_data, (legend_box_width - textWidth(min_data)) / 2, 0);
  textAlign(RIGHT, TOP);
  fill(0);
  text("max", num_colors * legend_box_width + textWidth("max") * 1.1, 0);
  fill(255);
  textAlign(LEFT, TOP);
  text(max_data, (num_colors - 1) * legend_box_width + (legend_box_width - textWidth(max_data)) / 2, 0);
  popMatrix();
}

int[][] draw_query_rect() {
  int[][] answer_matrix = new int[query_rows][query_columns];

  if(is_hovering(mouseX, mouseY)) {
    int num_of_boxes_x = floor((mouseX - start_pos_x) / box_width);
    int num_of_boxes_y = floor((mouseY - start_pos_y) / box_height);
    // These numbers tell how many boxes have been passed if one goes from the
    // top-left corner of the screen to where the mouse pointer is.

    if(is_timer_running) {
      pushMatrix();
      translate(start_pos_x, start_pos_y);
      translate(num_of_boxes_x * box_width, num_of_boxes_y * box_height);
      stroke(0);
      strokeWeight(7);
      noFill();
      rect(0, 0, query_columns * box_width, query_rows * box_height);
      popMatrix();
    }

    for(int i = 0; i < query_rows; i++) {
      for(int j = 0; j < query_columns; j ++) {
        answer_matrix[i][j] = data[i + num_of_boxes_y][j + num_of_boxes_x];
      }
    }
  }
  return answer_matrix;
}

boolean is_hovering(float x, float y) {
  // This function tells whether or not the user is hovering over the correct portion 
  // of the heat map. "Correct" here means a possible answer to the query can be selected.
  float ul_cor_x = start_pos_x;
  float ul_cor_y = start_pos_y;
  float lr_cor_x = (start_pos_x + box_width * (data_columns - query_columns + 1));
  float lr_cor_y = (start_pos_y + box_height * (data_rows - query_rows + 1));
  // upper-left and lower-right corners of the grid
  
  if(x > max(0, ul_cor_x) && x < min(650, lr_cor_x) && !is_game_over) {
      if(y > ul_cor_y && y < lr_cor_y) {
          return true;
      }
      else {
          return false;
      }
  }
  else {
      return false;
  }
}

void mouse_pressed_game() {
  if(!is_game_over) {
    if(is_hovering(mouseX, mouseY) && is_timer_running) {
      check_answer();
      is_game_setup = true;
    }
    else{
      if(mouseX > 698 + 170 + 2 * 50 / 3 && mouseX < 698 + 2 * 170 + 2 * 50 / 3 && mouseY > 20 && mouseY < 60) {
        mode = "settings";
      }
      else if(mouseX > 1090 && mouseY > 20 && mouseY < 60) {
        is_timer_running = !is_timer_running;
      }
    }
  }
  else {
    if(mouseY > 410 && mouseY < 450) {
      if(mouseX > 414 && mouseX < 584) {
        reset_game();
      }
      else if(mouseX > 616 && mouseX < 786) {
        time = settings_time;
        mode = "settings";
      }
    }
  }
}

void reset_game() {
  start_time = millis();
  time = settings_time;
  is_game_over = false;
  is_game_setup = true;
  is_timer_running = true;
  cur_score = 0;
}

void check_answer() {
  // This is equivalent to for-break-else in Python.
  int[][] answer_matrix = draw_query_rect();
  is_ans = true;
  start_time_ans = millis();

  check: {
    for(int i = 0; i < answer_matrix.length; i++) {
      for(int j = 0; j < answer_matrix[0].length; j++) {
        if(answer_matrix[i][j] != query[i][j]) {
          cur_score -= 1;
          is_correct_ans = false;
          break check;
        }
      }
    }
    cur_score += 1;
    is_correct_ans = true;
    if(high_score < cur_score) {
      high_score = cur_score;
    }
  }
}

void draw_ui() {

  // scores //

  textAlign(LEFT, BASELINE);

  // Black line to separate the game interface and the UI
  pushMatrix();
  translate(698, 0);
  noStroke();
  fill(0);
  rect(0, 0, 4, height);

  // White rectangle to prevent the heat map from spilling over
  translate(4, 0);
  noStroke();
  fill(255);
  rect(0, 0, width - 702, height);

  translate(50 / 3 - 4, 0);
  strokeWeight(3);
  stroke(0);

  noFill();
  rect(0, 80, 170, 80);
  rect(170 + 50 / 3, 80, 170, 80);
  if(!is_game_over) {
    fill(239, 246, 255);
    rect(170 + 50 / 3, 20, 170, 40);
    rect(392 - 50 / 3, 20, 108, 40);
  }

  translate(8.5, 33.5);
  textFont(header_font);
  textSize(30);
  fill(0);
  text("Current Score", 0, 80);
  textFont(text_font_2);
  textSize(40);
  text(cur_score, 75 - textWidth(cur_score) / 2, 120.5);

  textFont(header_font);
  textSize(30);
  translate(204.5, 0);
  text("High Score", 0, 80);

  if(!is_game_over) {
    text("Settings", 14, 18);

    if(is_timer_running) {
      text("Pause", 185, 18);
    }
    else{
      text("Play", 193.5, 18);

      pushMatrix();
      translate(-698 - 50 / 3 - 8.5 - 204.5, -33.5);
      fill(255, 240);
      rect(250, 410, 200, 80);
      textFont(text_font);
      fill(0);
      textSize(40);
      text("Paused", 350 - textWidth("Paused") / 2, 465);
      popMatrix();
    }
  }
  
  textFont(text_font_2);
  textSize(40);
  text(high_score, 59 - textWidth(high_score) / 2, 120.5);
  popMatrix();

  // timer //

  pushMatrix();
  translate(1090, 0);
  fill(0);
  stroke(0);
  strokeWeight(3);
  rect(0, 80, 108, 40);
  fill(0);
  rect(0, 120, 108, 40);

  textFont(header_font);
  textSize(30);
  translate(29, 33.5);
  fill(255);
  text("Time", 0, 80);
  textFont(text_font_2);
  textSize(40);

  if(is_timer_running) {
    cur_time = time - (millis() - start_time) / 1000;
  }
  else{
    time = cur_time;
    start_time = millis();
  }

  if(cur_time < 1) {
    cur_time = 0;
    is_game_over = true;
    is_timer_running = false;
  }

  int disp_time = int(cur_time);
  if(disp_time > 99) {
    text(int(disp_time), -2, 120.5);
  }
  else if(disp_time > 9) {
    text(int(disp_time), 7, 120.5);
  }
  else {
    text(int(disp_time), 16, 120.5); 
  }
  popMatrix();

  draw_query_matrix();

  if(is_game_over) {
    fill(255, 240);
    rect(380, 325, 440, 150);
    textFont(text_font);
    fill(0);
    textAlign(CENTER, TOP);
    textSize(50);
    text("GAME OVER", 600, 340);

    fill(239, 246, 255);
    rect(414, 410, 170, 40);
    rect(616, 410, 170, 40);

    fill(0);
    textFont(header_font);
    textSize(30);
    text("Play Again", 414 + 170 / 2, 412);
    text("Settings", 616 + 170 / 2, 412);
  }
}

void draw_query_matrix() {
  pushMatrix();

  // Draw header and borders.
  translate(800, 335);
  fill(0);
  textFont(header_font);
  textSize(30);
  textAlign(CENTER, BASELINE);
  text("Pattern to Find", 150, -10);
  stroke(0);
  strokeWeight(3);
  textFont(text_font_2);
  if(query_rows >= query_columns) {
    query_text_size = 300 / 2 / query_rows;
  }
  else{
   query_text_size = 300 / 2 / query_columns; 
  }
  textSize(query_text_size);
  textAlign(RIGHT, BASELINE);

  // Query matrix cell dimensions
  float dim_ratio = box_width / box_height;

  // float query_box_width = query_box_height = min(300 / query_columns, 300 / query_rows);
  float query_box_height = 300 / query_rows;
  float query_box_width = query_box_height * dim_ratio;

  float total_query_width = query_box_width * query_columns;
  if(total_query_width > 300) {
    query_box_width = 300 / total_query_width * query_box_width;
    query_box_height = query_box_width / dim_ratio;
  }

  translate((300 - query_box_width * query_columns) / 2, 0);

  // Required to offset the initial translations in the loop below.
  translate(-query_box_width, -query_box_height);

  for(int i = 0; i < query.length; i++) {
    translate(0, query_box_height);
    pushMatrix();
    for(int j = 0; j < query[0].length; j++) {
      translate(query_box_width, 0);
      fill(239, 246, 255);
      rect(0, 0, query_box_width, query_box_height);
      fill(0);
      textAlign(CENTER, CENTER);
      text(query[i][j], query_box_width / 2, query_box_height / 2);
    }
    popMatrix();
  }
  popMatrix();

  // Data matrix (in case it is needed)

  // pushMatrix();
  // fill(0);
  // textFont(text_font);
  // translate(750, 300);
  // for(int i = 0; i < data.length; i++) {
  //   for(int j = 0; j < data[0].length; j++) {
  //     text(data[i][j], 40 * j, 40 * i);
  //   }
  // }
  // popMatrix();
}

void draw_response() {
  if(is_ans) {
    textFont(text_font_2);
    textSize(40);
    fill(0, 255 - (millis() - start_time_ans) / 5);
    textAlign(CENTER, TOP);
    if(is_correct_ans) {
      text("+1", 791, 160);
    }
    else {
      text("-1", 792.5, 160);
    }
  }
}

/////////////////////
// End game screen //
/////////////////////

//////////////////
//////////////////
//// End Draw ////
//////////////////
//////////////////

////////////////////
////////////////////
//// Navigation ////
////////////////////
////////////////////

// void mouseScrolled(MouseEvent event) {
//   float cur_zoom = zoom;
//   zoom += mouseScroll * 0.02;
//   start_pos_x -= ((mouseX/cur_zoom * zoom) - mouseX) / zoom;
// }

// void mouseDragged() {
//   if (mouseButton == LEFT) {
//     start_pos_x += (mouseX - pmouseX) * 2;
//     start_pos_y += (mouseY - pmouseY) * 2;
//   }
// }

void mousePressed() {
  if(mode == "start") {
    mouse_pressed_start();
  }
  else if(mode == "settings") {
    mouse_pressed_settings();
  }
  else if(mode == "instructions") {
    mouse_pressed_instructions();
  }
  else if(mode == "game") {
    mouse_pressed_game();
  }
}

////////////////////////
////////////////////////
//// End navigation ////
////////////////////////
////////////////////////