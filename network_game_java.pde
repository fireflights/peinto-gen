/* @pjs font="./assets/fonts/Oswald-Light.ttf, ./assets/fonts/Oswald-Regular.ttf, ./assets/fonts/Oxygen-Regular.ttf"; */

String mode, game_state, medicine_state;
String[] start_pills;
int level;
Node[] nodes;
Drug[] drugs;
int pills_used, budget, tutorial_counter;
int[] start_nodes, level_states;
int[][] adj_matrix;
int[][] adj_matrix_checker;
LevelNode[] level_nodes;
boolean is_start_clicked, is_start_draw, is_game_setup_done, is_game_guide, is_tutorial;
Node selected_node;
PImage red_pill, blue_pill, start_screen_network;
PFont header_font, text_font, text_font_2;
float start_start_time, start_screen_angle;
// level_start_time_1, level_start_time_2, level_start_time_3, level_grow_time_1, level_grow_time_2, level_grow_time_3, level_screen_angle;
// int line_state;

void setup() {
	size(1200, 800, P2D);

	// Load fonts //
	header_font = createFont("./assets/fonts/Oswald-Regular.ttf", 48);
	text_font = createFont("./assets/fonts/Oxygen-Regular.ttf", 30);
	text_font_2 = createFont("./assets/fonts/Oswald-Light.ttf", 30);

	// Load images //
	red_pill = loadImage("./assets/img/red_pill.png");
	blue_pill = loadImage("./assets/img/blue_pill.png");
	start_screen_network = loadImage("./assets/img/start_screen.png");

	// Initialize settings //
	mode = "start";
	is_start_draw = true;
	is_start_clicked = false;
	is_game_guide = true;
	start_screen_angle = 0;

	level_states = new String[10]; // 0 = not available, 1 = available, 2 = done (not optimal), 3 = done (optimal)
	level_states[0] = 1;
	for(int i = 1; i < level_states.length; i++) {
		level_states[i] = 0;
	}
	// level_grow_time_1 = random(1000, 2000);
	// level_grow_time_2 = random(1000, 2000);
	// level_grow_time_3 = random(1000, 2000);

	level = 1;
	tutorial_counter = 0;
	is_tutorial = true;
	is_game_setup_done = false;
	game_state = "default";
}

////////////////////
////////////////////
//// Begin draw ////
////////////////////
////////////////////

void draw() {
	background(255);

	if(mode == "start") {
		start_screen();
	}
	else if(mode == "level") {
		is_game_setup_done = false;
		level_screen();
	}
	else if(mode == "game") {
		game_screen();
	} 
	else if(mode == "finish") {
		finish_screen();
	}
}

/////////////////////////
// Begin finish screen //
/////////////////////////

void finish_screen() {
	pushMatrix();
	translate(width/2, height/2);
	rotate(start_screen_angle);
	
	strokeWeight(3);

	rectMode(CENTER);
	imageMode(CENTER);
	if(is_start_draw == true) {
		start_start_time = millis();
		random_draw();
		is_start_draw = false;
	}

	float start_grow_time = 3000;
	float start_multiplier = min((millis() - start_start_time) / start_grow_time, 1);
	if(start_multiplier == 1) {
		is_start_draw = true;
	}

	if(start_multiplier < 0.5) {
		click_alpha = start_multiplier * 255 * 2;
	}
	else {
		click_alpha = 255 * 2 - start_multiplier  * 255 * 2;
	}

	for(int i = 0; i < 4; i++) {
		float rect_center_x = 300 * cos(i / 4 * 2 * PI + 2 * PI / 8);
		float rect_center_y = 300 * sin(i / 4 * 2 * PI + 2 * PI / 8);
		float node_center_x = 300 * cos(start_nodes[i] / 4 * 2 * PI);
		float node_center_y = 300 * sin(start_nodes[i] / 4 * 2 * PI);

		stroke(0);
		// fill(0, start_multiplier * 255);
		fill(0, click_alpha);
		if(start_pills[i] == "red") {
			stroke(193, 0, 1);
			// fill(255, 255 - start_multiplier * 255);
			fill(255, 255 - click_alpha);
			line(rect_center_x, rect_center_y, rect_center_x + start_multiplier * (node_center_x - rect_center_x), rect_center_y + start_multiplier * (node_center_y - rect_center_y));
			image(red_pill, rect_center_x, rect_center_y, 80, 80);
		}
		else if(start_pills[i] == "blue") {
			stroke(112, 171, 175);
			// fill(255, 255 - start_multiplier * 255);
			fill(255, 255 - click_alpha);
			line(rect_center_x, rect_center_y, rect_center_x + start_multiplier * (node_center_x - rect_center_x), rect_center_y + start_multiplier * (node_center_y - rect_center_y));
			image(blue_pill, rect_center_x, rect_center_y, 80, 80);
		}
		rect(rect_center_x, rect_center_y, 80, 80);
	}

	stroke(0);
	for(int i = 0; i < 4; i++) {
		float circ_center_x = 300 * cos(i / 4 * 2 * PI);
		float circ_center_y = 300 * sin(i / 4 * 2 * PI);
		fill(255);
		ellipse(circ_center_x, circ_center_y, 80, 80);
	}
	popMatrix();

	textFont(header_font);
	textSize(50);
	fill(0);
	text("Congratulations!", width/2  - textWidth("Congratulations!")/2, height/2 - 50);
	text("You have beaten the game!", width/2  - textWidth("You have beaten the game!")/2, height/2 + 20);
	textFont(text_font_2);
	text("(Click anywhere to go back to the start screen.)", width/2  - textWidth("(Click anywhere to go back to the start screen.)")/2, height/2 + 75);

	start_screen_rotate();
}

void mouse_pressed_finish() {
	is_start_clicked = false;
	mode = "start";
}

///////////////////////
// End finish screen //
///////////////////////

////////////////////////
// Begin start screen //
////////////////////////

void start_screen() {
	pushMatrix();
	translate(width/2, height/2);
	rotate(start_screen_angle);
	
	strokeWeight(3);

	rectMode(CENTER);
	imageMode(CENTER);
	if(is_start_draw == true) {
		start_start_time = millis();
		random_draw();
		is_start_draw = false;
	}

	float start_grow_time = 3000;
	float start_multiplier = min((millis() - start_start_time) / start_grow_time, 1);
	if(start_multiplier == 1) {
		is_start_draw = true;
	}

	if(start_multiplier < 0.5) {
		click_alpha = start_multiplier * 255 * 2;
	}
	else {
		click_alpha = 255 * 2 - start_multiplier  * 255 * 2;
	}

	for(int i = 0; i < 4; i++) {
		float rect_center_x = 300 * cos(i / 4 * 2 * PI + 2 * PI / 8);
		float rect_center_y = 300 * sin(i / 4 * 2 * PI + 2 * PI / 8);
		float node_center_x = 300 * cos(start_nodes[i] / 4 * 2 * PI);
		float node_center_y = 300 * sin(start_nodes[i] / 4 * 2 * PI);

		stroke(0);
		// fill(0, start_multiplier * 255);
		fill(0, click_alpha);
		if(start_pills[i] == "red") {
			stroke(193, 0, 1);
			// fill(255, 255 - start_multiplier * 255);
			fill(255, 255 - click_alpha);
			line(rect_center_x, rect_center_y, rect_center_x + start_multiplier * (node_center_x - rect_center_x), rect_center_y + start_multiplier * (node_center_y - rect_center_y));
			image(red_pill, rect_center_x, rect_center_y, 80, 80);
		}
		else if(start_pills[i] == "blue") {
			stroke(112, 171, 175);
			// fill(255, 255 - start_multiplier * 255);
			fill(255, 255 - click_alpha);
			line(rect_center_x, rect_center_y, rect_center_x + start_multiplier * (node_center_x - rect_center_x), rect_center_y + start_multiplier * (node_center_y - rect_center_y));
			image(blue_pill, rect_center_x, rect_center_y, 80, 80);
		}
		rect(rect_center_x, rect_center_y, 80, 80);
	}

	stroke(0);
	for(int i = 0; i < 4; i++) {
		float circ_center_x = 300 * cos(i / 4 * 2 * PI);
		float circ_center_y = 300 * sin(i / 4 * 2 * PI);
		fill(255);
		ellipse(circ_center_x, circ_center_y, 80, 80);
	}
	popMatrix();

	if(is_start_clicked) {
		pushMatrix();
		translate(width / 2, height / 2 + 40)
		rectMode(CENTER);
		strokeWeight(4);

		fill(255, 240);
		rect(0, -235, 360, 80);
		textFont(header_font);
		textAlign(CENTER, CENTER);
		textSize(65);
		fill(0);
		text("Dr. Node", 0, -235);
		textSize(50);
		fill(193, 0, 1);
		text("+", -35, -251);

		// fill(239, 246, 255, 240);
		fill(42, 85, 94, 200);
		rect(0, 0, 360, 390);
		fill(239, 246, 255, 240);
		rect(0, -117.5, 300, 80);
		rect(0, 0, 300, 80);
		textFont(text_font_2);
		textSize(50);
		fill(0);
		text("Start Game", 0, -117.5);
		text("Level Menu", 0, 0);

		if(is_game_guide) {
			fill(239, 246, 255, 240);
			rect(0, 117.5, 300, 80);
			fill(0);
			text("Game Guide On", 0, 117.5);
		}
		else {
			fill(255, 50);
			rect(0, 117.5, 300, 80);
			fill(255);
			text("Game Guide Off", 0, 117.5);	
		}
				
		popMatrix();
	}
	else {
		pushMatrix();
		translate(width / 2, height / 2 - 85);
		textFont(header_font);
		textAlign(CENTER, CENTER);
		fill(0);
		textSize(100);
		text("Dr.", -8, 0);
		text("Node", 0, 100);
		fill(193, 0, 1);
		text("+", 50, -25);
		textFont(text_font_2);

		float click_alpha_2;
		if(start_multiplier < 0.25) {
			click_alpha_2 = start_multiplier * 255 * 4;
		}
		else if(start_multiplier < 0.5) {
			click_alpha_2 = 255 - (start_multiplier - 0.25) * 255 * 4;
		}
		else if(start_multiplier < 0.75) {
			click_alpha_2 = (start_multiplier - 0.5) * 255 * 4;
		}
		else {
			click_alpha_2 = 255 - (start_multiplier - 0.75) * 255 * 4;
		}
		fill(0, click_alpha_2);
		text("Click anywhere to continue.", 0, 175);
		popMatrix();
	}

	start_screen_rotate();
}

void random_draw() {
	int rand_count, rand_color, tot_color;
	String cur_color;

	start_pills = new String[4];

	// While, not for, loop because it must be made sure that there's at least one active medical node.
	while(rand_count < 4) {
		rand_color = round(random(-0.5, 2.5));
		if(rand_color == 0) {
			cur_color = "none";
		}
		else if(rand_color == 1) {
			cur_color = "red";
			tot_color += 1;
		}
		else {
			cur_color = "blue";
			tot_color += 1;
		}
		start_pills[rand_count] = cur_color;
		rand_count += 1;
		if(rand_count == 4 && tot_color == 0) {
			rand_count = 0;
		}
	}

	start_nodes = new int[4];
	for(int i = 0; i < 4; i++) {
		if(start_pills[i] == "none") {
			start_nodes[i] = 0;
		}
		else {
			start_nodes[i] = round(random(-0.5, 3.5));
		}
	}
}

void start_screen_rotate() {
	start_screen_angle += 0.001;
}

void mouse_pressed_start() {
	if(!is_start_clicked) {
		is_start_clicked = true;
	}
	else {
		if(mouseX > 450 && mouseX < 750) {
			if(mouseY > 282.5 && mouseY < 362.5) {
				level = 1;
				mode = "game";
			}
			else if(mouseY > 400 && mouseY < 480) {
				mode = "level";
			}
			else if(mouseY > 517.5 && mouseY < 597.5) {
				is_game_guide = !is_game_guide;
			}
		}
	}
}

//////////////////////
// End start screen //
//////////////////////

////////////////////////
// Begin level screen //
////////////////////////

void level_screen() {
	pushMatrix();
	translate(width / 2 - 155, height / 2 + 72);
	rotate(start_screen_angle);

	rectMode(CENTER);
	imageMode(CENTER);
	if(is_start_draw == true) {
		start_start_time = millis();
		random_draw();
		is_start_draw = false;
	}

	float start_grow_time = 3000;
	float start_multiplier = min((millis() - start_start_time) / start_grow_time, 1);
	if(start_multiplier == 1) {
		is_start_draw = true;
	}

	if(start_multiplier < 0.5) {
		click_alpha = start_multiplier * 255 * 2;
	}
	else {
		click_alpha = 255 * 2 - start_multiplier  * 255 * 2;
	}

	for(int i = 0; i < 4; i++) {
		float rect_center_x = 500 * cos(i / 4 * 2 * PI + 2 * PI / 8);
		float rect_center_y = 500 * sin(i / 4 * 2 * PI + 2 * PI / 8);
		float node_center_x = 500 * cos(start_nodes[i] / 4 * 2 * PI);
		float node_center_y = 500 * sin(start_nodes[i] / 4 * 2 * PI);

		stroke(0);
		// fill(0, start_multiplier * 255);
		fill(0, click_alpha);
		if(start_pills[i] == "red") {
			stroke(193, 0, 1);
			// fill(255, 255 - start_multiplier * 255);
			fill(255, 255 - click_alpha);
			line(rect_center_x, rect_center_y, rect_center_x + start_multiplier * (node_center_x - rect_center_x), rect_center_y + start_multiplier * (node_center_y - rect_center_y));
			image(red_pill, rect_center_x, rect_center_y, 100, 100);
		}
		else if(start_pills[i] == "blue") {
			stroke(112, 171, 175);
			// fill(255, 255 - start_multiplier * 255);
			fill(255, 255 - click_alpha);
			line(rect_center_x, rect_center_y, rect_center_x + start_multiplier * (node_center_x - rect_center_x), rect_center_y + start_multiplier * (node_center_y - rect_center_y));
			image(blue_pill, rect_center_x, rect_center_y, 100, 100);
		}
		rect(rect_center_x, rect_center_y, 100, 100);
	}

	stroke(0);
	for(int i = 0; i < 4; i++) {
		float circ_center_x = 500 * cos(i / 4 * 2 * PI);
		float circ_center_y = 500 * sin(i / 4 * 2 * PI);
		fill(255);
		ellipse(circ_center_x, circ_center_y, 100, 100);
	}
	start_screen_rotate();
	popMatrix();

	if(is_game_guide) {
		pushMatrix();
		rectMode(CORNER);
		fill(0, 240);
		stroke(0);
		strokeWeight(2);
		translate(450, 5);

		rect(0, 0, 425, 25);
		textAlign(CENTER, CENTER);
		textFont(header_font);
		textSize(18);
		fill(255);
		text("Game Guide", 425 / 2, 25 / 2);

		translate(0, 25);
		fill(42, 85, 94, 240);
		rect(0, 0, 425, 82);
		fill(255);
		textFont(text_font);
		textSize(18);
		textAlign(LEFT, TOP);
		translate(6, 5);
		text("After completing a level, you automatically get one", 0, 0);
		translate(0, 24);
		text("star. To get two stars, you need to finish the level", 0, 0);
		translate(0, 24);
		text("with the minimum possible number of pills.", 0, 0);
		popMatrix();
	}

	rectMode(CENTER);
	stroke(0);
	strokeWeight(4);

	textFont(header_font);
	textAlign(CENTER, CENTER);

	fill(255, 240);
	rectMode(CENTER);
	rect(width / 2, 160, 1000, 80);
	textSize(65);
	fill(0);
	text("Levels", width / 2, 160);

	pushMatrix();
	translate(925, 62.5);
	rotate(0.93);
	fill(255);
	star(0, 0, 15, 35, 5);
	popMatrix();
	textFont(text_font);
	textSize(40);
	fill(0);
	int num_stars;
	for(int i = 0; i < level_states.length; i++) {
		if(level_states[i] > 1) {
			num_stars += level_states[i] - 1;
		}
	}
	text("= " + num_stars + "/20", 1100 - textWidth("= " + nf(num_stars, 2) + "/20")/2, 62.5);

	fill(239, 246, 255, 240);
	rect(width / 2, 640, 1000, 80);
	textFont(text_font_2);
	textAlign(CENTER, CENTER);
	textSize(50);
	fill(0);
	text("Back to start screen", width / 2, 640);

	// Earlier versions of level screen //

	// float interpolate_1, interpolate_2, interpolate_3;
	// // interpolate_1 = (millis() - level_start_time_1) / level_grow_time_1;
	// // interpolate_2 = (millis() - level_start_time_2) / level_grow_time_2;
	// // interpolate_3 = (millis() - level_start_time_3) / level_grow_time_3;

	// line(200, 280, 200 + interpolate_1 * 800, 280);
	// line(1000, 280, 1000 - interpolate_2 * 800, 280 + interpolate_2 * 200);
	// line(200, 480, 200 + interpolate_3 * 800, 480);
	// if(interpolate_1 >= 1) {
	// 	level_start_time_1 = millis();
	// 	level_grow_time_1 = random(1000, 2000);
	// }
	// if(interpolate_2 >= 1) {
	// 	level_start_time_2 = millis();
	// 	level_grow_time_2 = random(1000, 2000);
	// }
	// if(interpolate_3 >= 1) {
	// 	level_start_time_3 = millis();
	// 	level_grow_time_3 = random(1000, 2000);
	// }
	// int level_grow_time = 750; 

	// if(line_state == 0) {
	// 	interpolate_1 = (float)(millis() - level_start_time) / level_grow_time;
	// 	interpolate_2 = 0;
	// 	interpolate_3 = 0;
	// 	if(interpolate_1 >= 1) {
	// 		line_state = 1;
	// 		level_start_time = millis();
	// 	}
	// }
	// else if(line_state == 1) {
	// 	interpolate_1 = 1;
	// 	interpolate_2 = (float)(millis() - level_start_time) / level_grow_time;
	// 	interpolate_3 = 0;
	// 	if(interpolate_2 >= 1) {
	// 		line_state = 2;
	// 		level_start_time = millis();
	// 	}
	// }
	// else if(line_state == 2) {
	// 	interpolate_1 = 1;
	// 	interpolate_2 = 1;
	// 	interpolate_3 = (float)(millis() - level_start_time) / level_grow_time;
	// 	if(interpolate_3 >= 1) {
	// 		line_state = 0;
	// 		level_start_time = millis();
	// 	}
	// }
    
	// line(200, 250, (int)((1 - interpolate_1) * 200 + interpolate_1 * 1000), (int)((1 - interpolate_1) * 250 + interpolate_1 * 250));
	// line(1000, 250, (int)((1 - interpolate_2) * 1000 + interpolate_2 * 200), (int)((1 - interpolate_2) * 250 + interpolate_2 * 450));
	// line(200, 450, (int)((1 - interpolate_3) * 200 + interpolate_3 * 1000), (int)((1 - interpolate_3) * 450 + interpolate_3 * 450));
    
 	fill(42, 85, 94, 200);
	rect(width / 2, height / 2, 1000, 400);

	fill(0);
	textFont(text_font_2);
	level_nodes = new LevelNode[10];
	for(int i = 0; i < 2; i++) {
		for(int j = 0; j < 5; j++) {
			int index = i * 5 + j;
			float[] c = {200 + 200 * j, 305 + 190 * i}
			level_nodes[index] = new LevelNode(index + 1, c);
			level_nodes[index].draw();
		}
	}
}

void mouse_pressed_level() {
	for(int i = 0; i < 10; i++) {
		int ret = level_nodes[i].select();
		if(ret != -1 && level_states[i] > 0) {
			level = i + 1;
			mode = "game";
		}
	}
	
	if(mouseX > 100 && mouseX < 1100 && mouseY > 600 && mouseY < 680) {
		mode = "start";
	}
}

//////////////////////
// End level screen //
//////////////////////

///////////////////////
// Begin game screen //
///////////////////////

void game_screen() {
	game_tutorial();

	rectMode(CORNER);
	textAlign(LEFT, BASELINE);

	if(!is_game_setup_done) {
		setup_game_elements();
		is_game_setup_done = true;
	}
	if(game_state == "update_nodes") {
		for(int i = 0; i < drugs.length; i++) {
			if(medicine_state == drugs[i].type) {
				pills_used += 1;
			}
		}
		if(budget > 0) {
			for(int i = 0; i < adj_matrix.length; i++) {
				for(int j = 0; j < adj_matrix.length; j++) {
					adj_matrix_checker[i][j] = adj_matrix[i][j];
				}
			}
			if(medicine_state == "A") {
				update_nodes(selected_node, 1);
			}
			else {
				update_nodes(selected_node, -1);
			}
			
			int sum = 0;
			for(int i = 0; i < nodes.length; i++) {
				nodes[i].state = "default";
				sum += abs(nodes[i].value);
			}
			drugs[0].selected = false;
			drugs[1].selected = false;

			if(sum == 0) {
				game_state = "win";

				if(level_states[level - 1] != 3) {
					if(pills_used <= budget) {
						level_states[level - 1] = 3;
					}
					else {
						level_states[level - 1] = 2;
					}
				}

				if(level_states[level] == 0) {
					level_states[level] = 1;
				}
				
				if (level + 1 > 10) {
					mode = "finish";
				}
			}
			else {
				game_state = "default";
			}
		}
		else {
			game_state = "lose";
		}
		
	}

	draw_edges();
	for(int i = 0; i < nodes.length; i++) {
		nodes[i].draw();
	}
	drugs[0].draw();
	drugs[1].draw();

	// UI
	fill(0);
	textFont(header_font);
	textSize(50);
	text("Pills Used:", 117, 761);
	textFont(text_font_2);
	textSize(50)
	text(pills_used, 342 - textWidth(pills_used)/2, 761);

	draw_game_ui();

	if(game_state == "win" && is_updated_nodes()) {
		draw_win_prompt();
	}
}

void game_tutorial() {
	int header_size = 25;
	int header_height = 35;
	rectMode(CORNER);

	if(is_game_guide && is_tutorial) {
		if(level == 1) {
			if(tutorial_counter > 5) {
				is_tutorial = false;
			}

			if(tutorial_counter == 0) {
				float text_box_width = 265;
				float text_box_height = 40;

				pushMatrix();
				
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(465, 230);
				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("Welcome to Dr. Node!", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 1) {
				float text_box_width = 285;
				float text_box_height = 40;

				noFill();
				stroke(193, 0, 1);
				ellipse(785, 380, 100, 100);

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(850, 330);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("This is a standard node.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 2) {
				float text_box_width = 340;
				float text_box_height = 70;

				noFill();
				stroke(193, 0, 1);
				ellipse(785, 380, 100, 100);

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(850, 330);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("Your goal is to set the values", 0, 0);
				translate(0, 30);
				text("of all standard nodes to 0.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 3) {
				float text_box_width = 378;
				float text_box_height = 70;

				noFill();
				stroke(193, 0, 1);
				ellipse(415, 380, 130, 130);
				rect(485, 685, 230, 112.5);

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(250, 490);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("To do this, you must use pills on", 0, 0);
				translate(0, 30);
				text("these square medicine nodes.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 4) {
				float text_box_width = 378;
				float text_box_height = 130;

				noFill();
				stroke(193, 0, 1);
				ellipse(600, 380, 50, 50);
				rect(485, 685, 230, 112.5);

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(410, 450);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("The plus and minus pills have", 0, 0);
				translate(0, 30);
				text("different effects depending on", 0, 0);
				translate(0, 30);
				text("the values of the connections", 0, 0);
				translate(0, 30);
				text("between nodes.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 5) {
				float text_box_width = 378;
				float text_box_height = 100;

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(410, 460);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(15, 4);
				text("Try to use both pills and repeat", 0, 0);
				translate(0, 30);
				text("this level until you understand", 0, 0);
				translate(0, 30);
				text("how the nodes interact.", 0, 0);
				translate(-15, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
		}
		else if(level == 2) {
			if(tutorial_counter > 4) {
				is_tutorial = false;
			}
			
			if(tutorial_counter == 0) {
				float text_box_width = 305;
				float text_box_height = 70;

				noFill();
				stroke(193, 0, 1);
				ellipse(600, 455, 50, 50);

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(550, 500);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("Two standard nodes may", 0, 0);
				translate(0, 30);
				text("also be connected.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 1) {
				float text_box_width = 427;
				float text_box_height = 100;

				noFill();
				stroke(193, 0, 1);
				ellipse(600, 455, 50, 50);
				ellipse(785, 380, 100, 100);

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(550, 500);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("What this connection does depends", 0, 0);
				translate(0, 30);
				text("on what happens to the node on the", 0, 0);
				translate(0, 30);
				text("right (the source node).", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 2) {
				float text_box_width = 318;
				float text_box_height = 70;

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(35, 170);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("Note that you can only use", 0, 0);
				translate(0, 30);
				text("pills on medicine nodes.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 3) {
				float text_box_width = 323;
				float text_box_height = 100;

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(35, 160);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("Again, try both pills and", 0, 0);
				translate(0, 30);
				text("repeat this level until you", 0, 0);
				translate(0, 30);
				text("understand the interaction.", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
			else if(tutorial_counter == 4) {
				float text_box_width = 305;
				float text_box_height = 100;

				pushMatrix();
				fill(0, 240);
				stroke(0);
				strokeWeight(2);
				translate(45, 160);

				rect(0, 0, text_box_width, header_height);
				textAlign(CENTER, CENTER);
				textFont(header_font);
				textSize(header_size);
				fill(255);
				text("Game Guide", text_box_width / 2, header_height / 2);

				translate(0, header_height);
				fill(42, 85, 94, 240);
				rect(0, 0, text_box_width, text_box_height);
				fill(255);
				textFont(text_font);
				textSize(25);
				textAlign(LEFT, TOP);
				translate(10, 4);
				text("This is the last level with", 0, 0);
				translate(0, 30);
				text("a tutorial. Good luck, and", 0, 0);
				translate(0, 30);
				text("we hope you have fun!", 0, 0);
				translate(-10, 40);
				textFont(header_font);
				textAlign(CENTER, TOP);
				textSize(18);
				fill(0);
				text("(Click anywhere to continue)", text_box_width / 2, 0);
				popMatrix();
			}
		}
		else {
			is_tutorial = false;
		}
	}
}

boolean is_updated_nodes() {
	for(int i = 0; i < nodes.length; i++) {
		if(nodes[i].old_value != nodes[i].value) {
			return false;
		}
	}
	return true;
}

void mouse_pressed_game() {
	if(is_game_guide && is_tutorial) {
		tutorial_counter += 1
	}
	else {
		click_game_ui();

		for(int i = 0; i < nodes.length; i++) {
			nodes[i].select();
		}
		drugs[0].select();
		drugs[1].select();
		if(game_state == "win") {
			click_win_prompt();
		}
	}
}

void draw_win_prompt() {
	fill(255, 240);
	rect(300, 310, 600, 150);

	fill(239, 246, 255, 240);
	rect(300, 385, 200, 75);
	rect(500, 385, 200, 75);
	rect(700, 385, 200, 75);

	fill(0);
	textFont(header_font);
	text("Great job!", 515, 368);
	textFont(text_font_2);
	textSize(40);
	text("Repeat Level", 400 - textWidth("Repeat Level") / 2, 440);
	text("Level Menu", 600 - textWidth("Level Menu") / 2, 440);
	text("Next Level", 800 - textWidth("Next Level") / 2, 440);
}

void click_win_prompt() {
	if(mouseX > 300 && mouseX < 500 && mouseY > 385 && mouseY < 460) {
		is_game_setup_done = false;
		game_state = "default";
	}

	if(mouseX > 500 && mouseX < 700 && mouseY > 385 && mouseY < 460) {
		mode = "level";
		is_game_setup_done = false;
		game_state = "default";
	}

	if(mouseX > 700 && mouseX < 900 && mouseY > 385 && mouseY < 460) {
		level += 1;
		is_tutorial = true;
		tutorial_counter = 0;
		is_game_setup_done = false;
		game_state = "default";
	}
}

void click_game_ui() {
	if(mouseX > 828 && mouseX < 1080 && mouseY > 710.5 && mouseY < 770.5) {
		is_game_setup_done = false;
		game_state = "default";
	}
	if(mouseX > 243 && mouseX < 543 && mouseY > 9 && mouseY < 69) {
		is_game_setup_done = false;
		mode = "level";
	}
	if(level != 1 && mouseX > 585 && mouseX < 885 && mouseY > 9 && mouseY < 69) {
		level -= 1;
		is_game_setup_done = false;
		game_state = "default";
	}
	if(level != 10 && mouseX > 895 && mouseX < 1195 && mouseY > 9 && mouseY < 69 && level_states[level] > 0) {
		level += 1;
		is_game_setup_done = false;
		game_state = "default";
	}
	if(is_game_guide && !is_tutorial) {
		if(level == 1 || level == 2) {
			if(mouseX > 10 && mouseX < 190 && mouseY > 95 && mouseY < 140) {
				is_tutorial = true;
				tutorial_counter = 0;
			}
		}
	}
}

void draw_game_ui() {
	pushMatrix();
	noStroke();
	fill(0);
	translate(0, 78.5);
	rect(0, 0, 1200, 3);

	translate(0, 600);
	rect(0, 0, 1200, 3);
	popMatrix();

	stroke(0);
	fill(255);
	strokeWeight(3);
	
	// Current level //
	fill(42, 85, 94, 200);
	rect(0, 0, 200, 80);
	textFont(header_font);
	fill(255);
	text("Level " + level.toString(), 100 - textWidth("Level " + level.toString()) / 2, 60);

	if(game_state != "win") {
		// Restart //
		fill(239, 246, 255, 240);
		rect(828, 710.5, 252, 60);
		textFont(header_font);
		textSize(50);
		fill(0);
		text("Restart Level", 835.5, 761);

		// Repeat Tutorial //
		if(level == 1 || level == 2) {
			if(is_game_guide && !is_tutorial) {
				fill(239, 246, 255, 240);
				rect(10, 95, 180, 45);
				textFont(header_font);
				textSize(30);
				fill(0);
				text("Repeat Tutorial", 183 - textWidth("Repeat Tutorial"), 130);
			}
		}

		// Level menu //
		fill(239, 246, 255, 240);
		rect(243, 9, 300, 60);
		textFont(header_font);
		textSize(50);
		fill(0);
		text("Level Menu", 293.5, 60);

		// Previous level //
		if(level > 1) {
			fill(239, 246, 255, 240);
			rect(585, 9, 300, 60);
			textFont(header_font);
			textSize(50);
			fill(0);
			triangle(597, 40, 609, 25, 609, 55);
			text("Previous Level", 619, 60);
		}

		// Next level //
		if(level < 10 && level_states[level] > 0) {
			fill(239, 246, 255, 240);
			rect(895, 9, 300, 60);
			textFont(header_font);
			textSize(50);
			fill(0);
			triangle(1183, 40, 1171, 25, 1171, 55);
			text("Next Level", 945, 60);
		}
	}
}

void update_nodes(Node curr_node, int value) {
	int curr_node_index = curr_node.index;
	int[] connections = adj_matrix[curr_node_index];
	int[] check_connections = adj_matrix_checker[curr_node_index];
	if(curr_node.type != "Med") {
		curr_node.value += value;
		curr_node.timer = millis();
	}
	for(int i = 0; i < connections.length; i++) {
		if(connections[i] != 0 && check_connections[i] != 0) {
			int new_value = connections[i]*value;
			adj_matrix_checker[curr_node_index][i] = 0;
			update_nodes(nodes[i], new_value);
		}
	}
}


void setup_game_elements() {
	String level_file = "./data/level_" + level.toString() + ".txt";
	String[] data = loadStrings(level_file);
	int pointer = 0;

	String[] init_values = data[pointer].split(" ");
	int num_med_nodes = int(init_values[0]);
	int num_reg_nodes = int(init_values[1]);
	int total_nodes = num_med_nodes + num_reg_nodes;
	nodes = new Node[total_nodes];
	for(int i = 0; i < num_med_nodes; i++) {
		String[] values = data[pointer+i+1].split(" ");
		nodes[i] = new Node(values[0], i, {float(values[1]), float(values[2])}, "Med", 0);
	}

	pointer += num_med_nodes + 1;

	for(int i = num_med_nodes; i < total_nodes; i++) {
		String[] values = data[pointer+i-num_med_nodes].split(" ");
		nodes[i] = new Node(values[0], i, {float(values[2]), float(values[3])}, "Reg", int(values[1]));
	}

	pointer += num_reg_nodes + 1;

	adj_matrix = new int[total_nodes][total_nodes];
	adj_matrix_checker = new int[total_nodes][total_nodes];

	int num_connections = int(data[pointer]);
	for(int i = 0; i < num_connections; i++) {
		String[] values = data[pointer+i+1].split(" ");
		int index1 = get_index_of_node_name(values[0]);
		int index2 = get_index_of_node_name(values[1]);
		int value = int(values[2]);
		adj_matrix[index1][index2] = value;
	}

	pointer += num_connections + 2;
	drugs = new Drug[2];
	int activation_drug_price = int(data[pointer]);
	drugs[0] = new Drug("A", activation_drug_price);
	int inhibition_drug_price = int(data[pointer+1]);
	drugs[1] = new Drug("I", inhibition_drug_price);
	budget = int(data[pointer+2]);
	pills_used = 0;
}

void draw_edges(){
	for(int i = 0; i < adj_matrix.length; i++) {
		for(int j = 0; j < adj_matrix.length; j++) {
			int value = adj_matrix[i][j];
			if(value != 0) {
				strokeWeight(3);
				float[] from = nodes[i].mid_coordinates;
				float[] to = nodes[j].mid_coordinates;
				stroke(0);
				draw_arrow(40, from, to);
				fill(0);
				ellipse((from[0]+to[0])/2, (from[1]+to[1])/2, 32, 32);
				fill(255);
				textFont(text_font_2);
				textSize(20);
				text(value, (from[0]+to[0])/2 - textWidth(value) / 2, (from[1]+to[1])/2 + 8);
			}
		}
	}
}

//////////////////
//////////////////
//// End draw ////
//////////////////
//////////////////

void mousePressed() {
	if(mode == "start") {
		mouse_pressed_start();
	}
	else if(mode == "level") {
		mouse_pressed_level();
	}
	else if(mode == "game") {
		mouse_pressed_game();
	}
	else if(mode == "finish") {
		mouse_pressed_finish();
	}
}

int get_index_of_node_name(String name) {
	for(int i = 0; i < nodes.length; i++) {
		String node_name = nodes[i].name;
		if(node_name == name) {
			return nodes[i].index;
		}
	}
}

void draw_arrow(float radius, float[] center_circ1, float[] center_circ2) { 
  float x1 = center_circ1[0];
  float y1 = center_circ1[1];
  float x2 = center_circ2[0];
  float y2 = center_circ2[1];
  float dist_bet_circs = dist(x1, y1, x2, y2);
  
  float new_x1, new_x2, new_y1, new_y2;
  if(x1 < x2) {
    new_x1 = x1 + radius / dist_bet_circs * (x2 - x1);
    new_x2 = x2 - radius / dist_bet_circs * (x2 - x1);
  }
  else {
    new_x1 = x1 - radius / dist_bet_circs * (x1 - x2);
    new_x2 = x2 + radius / dist_bet_circs * (x1 - x2);
  }
  if(y1 > y2) {
    new_y1 = y1 + radius / dist_bet_circs * (y2 - y1);
    new_y2 = y2 - radius / dist_bet_circs * (y2 - y1);
  }
  else {
    new_y1 = y1 - radius / dist_bet_circs * (y1 - y2);
    new_y2 = y2 + radius / dist_bet_circs * (y1 - y2);
  }
  
  line(new_x1, new_y1, new_x2, new_y2);
  
  pushMatrix();
  translate(new_x2, new_y2);
  float theta = acos((new_x1 - new_x2)/dist(new_x1, new_y1, new_x2, new_y2));
  if(new_y2 > new_y1) {
    rotate(-theta - PI / 4);
    line(0, 0, 10, 0);
    rotate(PI / 2);
    line(0, 0, 10, 0);
  }
  else {
    rotate(theta + PI / 4);
    line(0, 0, 10, 0);
    rotate(-PI / 2);
    line(0, 0, 10, 0);
  }
  popMatrix();
}

public interface Drawable {
	public void draw();
}

public interface Selectable {
	public void select();
}

class LevelNode implements Drawable {
	int level;
	float[] coordinates;
	boolean selected;
	public LevelNode(int level, float coordinates) {
		this.level = level;
		this.coordinates = coordinates;
		selected = false;
	}

	public void draw() {
		if(level_states[this.level - 1] == 0) {
			fill(0);
		}
		else {
			fill(239, 246, 255);
		}
		ellipseMode(CENTER);
		strokeWeight(3);
		ellipse(coordinates[0], coordinates[1], 120, 120);
		textFont(text_font);
		fill(0);
		textAlign(CENTER, CENTER);
		textSize(50);
		text(level, coordinates[0], coordinates[1]);
		textAlign(LEFT);

		textFont(header_font);
		textSize(40);
		fill(42, 85, 94);
		if(level_states[this.level - 1] == 2) {
			pushMatrix();
			translate(coordinates[0] - 30, coordinates[1]);
			rotate(0.93);
			fill(255);
			star(0, 0, 4, 14 * 2 / 3, 5);
			popMatrix();
		}
		else if(level_states[this.level - 1] == 3) {
			pushMatrix();
			translate(coordinates[0] - 30, coordinates[1]);
			rotate(0.93);
			fill(255);
			star(0, 0, 4, 14 * 2 / 3, 5);
			popMatrix();
			pushMatrix();
			translate(coordinates[0] + 30, coordinates[1]);
			rotate(0.93);
			fill(255);
			star(0, 0, 4, 14 * 2 / 3, 5);
			popMatrix();
		}
	}

	public int select() {
		float d = dist(mouseX, mouseY, coordinates[0], coordinates[1]);
		if(d < 60) {
			selected = true;
			return level;		
		}
		return -1;
	}
}

class Node implements Drawable, Selectable {
	String name, type, state;
	float coordinates;
	float mid_coordinates;
	int old_value;
	float timer;
	int value;
	int index;
	int[] color;
	boolean selected;
	int alpha_delta;
	public Node(String name, int index, float coordinates, String type, int value) {
		this.name = name;
		this.index = index;
		this.coordinates = coordinates;
		this.type = type;
		if(type == "Med") {
			this.mid_coordinates = {coordinates[0] + 40, coordinates[1] + 40};
		}
		else {
			this.mid_coordinates = coordinates;
		}
		this.value = value;
		this.old_value = value;
		this.highlight = false;
		this.color = {239, 246, 255};
		this.selected = false;
		this.state = "default";
		this.alpha_delta = 0;
		this.timer = millis() - 1001;
	}

	public void draw() {
		strokeWeight(3);
		if(game_state == "select_node" && this.type == "Med") {
			if(medicine_state == "A") {
				stroke(0);
				fill(112,171,175);
			}
			else {
				stroke(0);
				fill(193,0,1);
			}
		}
		else {
			fill(this.color[0], this.color[1], this.color[2]);
			stroke(0);
		}
		if(this.type == "Med"){
			rect(this.coordinates[0], this.coordinates[1], 80, 80);
		}
		else {
			ellipse(this.coordinates[0], this.coordinates[1], 80, 80);
			textFont(text_font);
			textSize(30);

			int temp_value = value;
			float diff = millis() - this.timer;
			if(diff <= 500) {
				fill(0,0,0, 255 - int(255*(diff/500)));
				temp_value = old_value
			}
			else if(diff > 500 && diff < 1000) {
				fill(0,0,0, int(255*((diff-500)/500)));

			}
			else {
				fill(0,0,0, 255);
				old_value = value;
			}
			text(temp_value, this.mid_coordinates[0] - textWidth(temp_value) / 2, this.mid_coordinates[1] + 10);
		}
		if(selected) {
			this.color = {239, 246, 255};
			selected = false; 
		}


	}

	public void select() {
		float distance_x = abs(mouseX - mid_coordinates[0]);
		float distance_y = abs(mouseY - mid_coordinates[1]);
		if(this.type == "Med" && game_state == "select_node") {
			if (distance_x < 40 && distance_y < 40) {
				this.color[0] = 0;
				this.color[1] = 0;
				this.color[2] = 0;
				selected = true;
				game_state = "update_nodes";
				selected_node = this;
			}
		}
	}
}

class Drug implements Drawable, Selectable {
	String type;
	int value;
	int[] color;
	int[] mid_coordinates, coordinates;
	boolean selected;
	public Drug(String type, int value) {
		this.type = type;
		this.value = value;
		if(type == "I") {
			color = {0, 0, 0};
			coordinates = {493, 690.5};
		}
		else {
			color = {255, 255, 255};
			coordinates = {607, 690.5};
		}
		this.mid_coordinates = {coordinates[0] + 50, coordinates[1] + 50};
	}

	public void draw() {
		
		strokeWeight(5);
		if(selected && this.type == medicine_state) {
			if(type == "A") {
				stroke(112,171,175);
			}
			else {
				stroke(193,0,1);
			}
		}
		else {
			stroke(0);
		}
		fill(this.color[0], this.color[1], this.color[2]);
		rect(coordinates[0], coordinates[1], 100, 100);
		
		imageMode(CORNER);
		if(type == "A") {
			image(blue_pill, coordinates[0], coordinates[1], 100, 100);
		}
		else {
			image(red_pill, coordinates[0], coordinates[1], 100, 100);
		}
  		

	}

	public void select() {
		float distance_x = abs(mouseX - mid_coordinates[0]);
		float distance_y = abs(mouseY - mid_coordinates[1]);
		if(distance_x < 50 && distance_y < 50) {
			if(game_state == "default" || game_state == "select_node") {
				if(type == "I") {
					this.color[0] = 255;
					this.color[1] = 255;
					this.color[2] = 255;
					medicine_state = "I";
				}
				else {
					this.color[0] = 0;
					this.color[1] = 0;
					this.color[2] = 0;
					medicine_state = "A";
				}
				selected = true;
				game_state = "select_node";
			}
			
		}
	}
}

void star(float x, float y, float radius1, float radius2, int npoints) {
	strokeWeight(1.5);
	float angle = TWO_PI / npoints;
	float halfAngle = angle/2.0;
	beginShape();
	for (float a = 0; a < TWO_PI; a += angle) {
  		float sx = x + cos(a) * radius2;
    	float sy = y + sin(a) * radius2;
    	vertex(sx, sy);
    	sx = x + cos(a+halfAngle) * radius1;
    	sy = y + sin(a+halfAngle) * radius1;
    	vertex(sx, sy);
  	}
  	endShape(CLOSE);
}