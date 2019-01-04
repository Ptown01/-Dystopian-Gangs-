if !file_exists("world.dat"){
		//create grid
		wGrid = ds_grid_create(get_integer("width of world",10),get_integer("height of world",10));
	
		//save grid
		ini_open("world.dat");
		ini_write_string("world", "grid", ds_grid_write(wGrid));	
		ini_close();
	
	}else{
			//load world
			wGrid = ds_grid_create(10,10);
		
			ini_open("Save.ini");
			ds_grid_read(wGrid, ini_read_string("world", "grid", ""));
			ini_close();
		
		}
		