#define whs_event_game_start
/// whs_event_game_start(username,password)
global.whs_socket = network_create_socket(network_socket_tcp);
network_connect_raw(global.whs_socket, "185.244.130.63", 6800);

global.whs_username = real(argument0);
global.whs_password = real(argument1);

global.whs_readable = buffer_create(1, buffer_grow, 1);
global.whs_writable = buffer_create(1, buffer_grow, 1);

global.whs_callback_connect = undefined;
global.whs_callback_account = undefined;
global.whs_callback_session = undefined;
global.whs_callback_streams = undefined;
global.whs_callback_message = undefined;
global.whs_callback_matches = undefined;

global.whs_format_game = "{name}: {text}";
global.whs_format_room = "{name}: {text}";
global.whs_format_user = "{name}: {text}";

global.whs_other_player = undefined;
global.whs_other_delays = 75;

global.whs_ini = ds_map_create();
global.whs_all = ds_map_create();
global.whs_obj = ds_map_create();

global.whs_room = undefined;

global.whs_player = 0;
global.whs_online = 0;

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 1);
buffer_write(global.whs_writable, buffer_f64, global.whs_username);
buffer_write(global.whs_writable, buffer_f64, global.whs_password);
buffer_write(global.whs_writable, buffer_string, game_display_name);
buffer_write(global.whs_writable, buffer_string, game_project_name);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

show_debug_message("WHS: Sending a connection request");

#define whs_event_game_end
/// whs_event_game_end()
network_destroy(global.whs_socket);

buffer_delete(global.whs_readable);
buffer_delete(global.whs_writable);

ds_map_destroy(global.whs_ini);

#define whs_event_networking
/// whs_event_networking()
if (async_load[? "id"] != global.whs_socket) return 0;
buffer_copy(async_load[? "buffer"], 0, async_load[? "size"], global.whs_readable, buffer_tell(global.whs_readable));

var size = buffer_peek(global.whs_readable, 0, buffer_u16);
var type = buffer_peek(global.whs_readable, 2, buffer_u16);

while (buffer_get_size(global.whs_readable) >= size) {
   var size = buffer_read(global.whs_readable, buffer_u16);
   var type = buffer_read(global.whs_readable, buffer_u16);
   
   if (type = 0) {
      var error = buffer_read(global.whs_readable, buffer_string);
      show_error("WHS server side error: "+string(error), 1);
   }
   
   if (type = 1) {
      show_debug_message("WHS: Connection has been accepted");
      global.whs_player = buffer_read(global.whs_readable, buffer_u32);
      global.whs_online = 1;
      
      if (global.whs_callback_connect != undefined) {
         script_execute(global.whs_callback_connect);
      }
   }
   
   if (type = 2) {
      var index = buffer_read(global.whs_readable, buffer_u16);
      var value = buffer_read(global.whs_readable, buffer_s32);

      if (index = 1) global.constant = value;
   }
   
   if (type = 3) {
      var sec = buffer_read(global.whs_readable, buffer_string);
      var key = buffer_read(global.whs_readable, buffer_string);
      var format = buffer_read(global.whs_readable, buffer_u8);
      
      show_debug_message("WHS: INI format "+string(format));
      
      if (format = 1) {value = buffer_read(global.whs_readable, buffer_string)}
      if (format = 2) {value = buffer_read(global.whs_readable, buffer_f64)}
      if (format = 3) {value = buffer_read(global.whs_readable, buffer_bool)}
      
      show_debug_message("WHS: INI value "+string(value));
      
      if (ds_map_exists(global.whs_ini, sec)) {
         var section = ds_map_find_value(global.whs_ini, sec);
         ds_map_add(section, key, value);
      }
   }
   
   if (type = 4) {
      var kind = buffer_read(global.whs_readable, buffer_u8);
      var call = buffer_read(global.whs_readable, buffer_u8);
      
      if (global.whs_callback_account != undefined) {
         script_execute(global.whs_callback_account, kind, call);
      }
   }
   
   if (type = 5) {
      var kind = buffer_read(global.whs_readable, buffer_u8);
      
      if (kind = 1) {
         global.whs_room = buffer_read(global.whs_readable, buffer_string);
         show_debug_message("WHS: Entered room " + global.whs_room);
      }
      
      if (kind = 2) {
         global.whs_room = undefined;
         ds_map_clear(global.whs_all);
         ds_map_clear(global.whs_obj);
      }
      
      if (global.whs_callback_session != undefined) {
         script_execute(global.whs_callback_session, kind);
      }
   }
   
   if (type = 6) {
      var callback = buffer_read(global.whs_readable, buffer_string);
      
      if (global.whs_callback_message != undefined) {
         script_execute(global.whs_callback_message, callback);
      }
   }
   
   if (type = 7) {
      var callback = buffer_read(global.whs_readable, buffer_u8);
      var index = buffer_read(global.whs_readable, buffer_u32);
      
      var player = string(index);
      
      if (callback = 1) {
         var xx = buffer_read(global.whs_readable, buffer_u16);
         var yy = buffer_read(global.whs_readable, buffer_u16);
         if (ds_map_exists(global.whs_all, player)) {
            var instance = ds_map_find_value(global.whs_all, player);
            (instance).whs_x = xx;
            (instance).whs_y = yy;
         } else {
            if (global.whs_other_player != undefined) {
               var instance = instance_create(xx, yy, global.whs_other_player);
               ds_map_add(global.whs_all, player, instance);
            } else {
               show_error("WHS: Other player showed up, but no instance binded", 1);
            }
         }
      }
      
      if (callback = 2) {
         if (ds_map_exists(global.whs_all, player)) {
            var instance = ds_map_find_value(global.whs_all, player);
            ds_map_delete(global.whs_all, player);
            with (instance) instance_destroy();
         } else {
            show_debug_message("WHS: Got a request to destroy undefined player.");
         }
      }
      
      if (callback = 3) {
         // Set a variable
      }
   }
   
   if (type = 8) {
      var callback = buffer_read(global.whs_readable, buffer_u8);
      var instance = buffer_read(global.whs_readable, buffer_u16);
      
      if (callback = 1) {
         var xx = buffer_read(global.whs_readable, buffer_u16);
         var yy = buffer_read(global.whs_readable, buffer_u16);
         var obj = buffer_read(global.whs_readable, buffer_u16);
         if (!ds_map_exists(global.whs_obj, string(instance))) {
            global.whs_obj[? string(instance)] = instance_create(xx, yy, obj);
         }
      }
      
      if (callback = 2) {
         var xx = buffer_read(global.whs_readable, buffer_u16);
         var yy = buffer_read(global.whs_readable, buffer_u16);
         if (ds_map_exists(global.whs_obj, string(instance))) {
            (global.whs_obj[? string(instance)]).x = xx;
            (global.whs_obj[? string(instance)]).y = yy;
         }
      }
      
      if (callback = 3) {
         if (ds_map_exists(global.whs_obj, string(instance))) {
            with (global.whs_obj[? string(instance)]) {
               instance_destroy();
            }
            ds_map_delete(global.whs_obj, string(instance));
         }
      }
   }
   
   if (type = 9) {
      var stream = buffer_create(1, buffer_grow, 1);
      buffer_copy(global.whs_readable, buffer_tell(global.whs_readable), buffer_get_size(global.whs_readable), stream, 0);
      
      show_debug_message("WHS: Received readable stream chunk");
      
      if (global.whs_callback_streams != undefined) {
         script_execute(global.whs_callback_streams, stream);
      } else {
         buffer_delete(stream);
      }
   }
   
   if (type = 10) {
      var kind = buffer_read(global.whs_readable, buffer_u8);
      var time = date_time_string(date_current_datetime());
      var date = date_datetime_string(date_current_datetime());
      var name = buffer_read(global.whs_readable, buffer_string);
      var text = buffer_read(global.whs_readable, buffer_string);
      var message = "";
      
      if (kind = 1) {
         message = global.whs_format_game;
         message = string_replace_all(message, "{time}", time);
         message = string_replace_all(message, "{date}", date);
         message = string_replace_all(message, "{name}", name);
         message = string_replace_all(message, "{text}", text);
      }
      
      if (kind = 2) {
         message = global.whs_format_room;
         message = string_replace_all(message, "{time}", time);
         message = string_replace_all(message, "{date}", date);
         message = string_replace_all(message, "{name}", name);
         message = string_replace_all(message, "{text}", text);
      }
      
      if (kind = 3) {
         message = global.whs_format_user;
         message = string_replace_all(message, "{time}", time);
         message = string_replace_all(message, "{date}", date);
         message = string_replace_all(message, "{name}", name);
         message = string_replace_all(message, "{text}", text);
      }
      
      if (global.whs_callback_message != undefined) {
         script_execute(global.whs_callback_message, message);
      }
   }
   
   if (type = 11) {
      var kind = buffer_read(global.whs_readable, buffer_u8);
      
      if (kind = 1) {
         var player = buffer_read(global.whs_readable, buffer_string);
         
         show_debug_message("WHS: Found match "+player);
         if (global.whs_callback_matches != undefined) {
            script_execute(global.whs_callback_matches, kind, player);
         }
      }
      
      if (kind = 2) {
         show_debug_message("WHS: Match search has ended");
         if (global.whs_callback_matches != undefined) {
            script_execute(global.whs_callback_matches, kind);
         }
      }
   }
   
   var buffer = global.whs_readable;
   buffer_seek(buffer, buffer_seek_start, 0);
   global.whs_readable = buffer_create(1, buffer_grow, 1);
   if (buffer_tell(buffer) < buffer_get_size(buffer)) {
      buffer_copy(buffer, size, buffer_get_size(buffer), global.whs_readable,  0);
      var size = buffer_peek(global.whs_readable, 0, buffer_u16);
      var type = buffer_peek(global.whs_readable, 2, buffer_u16);
   }
   buffer_delete(buffer);
   if (buffer_get_size(global.whs_readable) < 4) break;
}

#define whs_info_player
/// whs_info_player()
return global.whs_player;

#define whs_info_online
/// whs_info_online()
return global.whs_online;

#define whs_ini_enter
/// whs_ini_enter(section)
if (!is_string(argument0)) {
   show_error("WHS: INI section must be a string", 1);
}

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 3);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

ds_map_add_map(global.whs_ini, argument0, ds_map_create());

#define whs_ini_leave
/// whs_ini_leave(section)
if (!is_string(argument0)) {
   show_error("WHS: INI section must be a string", 1);
}

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 3);
buffer_write(global.whs_writable, buffer_u8, 2);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

ds_map_destroy(ds_map_find_value(global.whs_ini, argument0));
ds_map_delete(global.whs_ini, argument0);

#define whs_ini_exist
/// whs_ini_exist(section,key)
if (!is_string(argument0)) {
   show_error("WHS: INI section must be a string", 1);
}

if (!is_string(argument1)) {
   show_error("WHS: INI key must be a string", 1);
}

if (!ds_map_exists(global.whs_ini, argument0)) {
   show_error("WHS: You must join INI section before modifying it", 1);
}

var section = ds_map_find_value(global.whs_ini, argument0);
return ds_map_exists(section, argument1);

#define whs_ini_write
/// whs_ini_write(section,key,value)
if (!is_string(argument0)) {
   show_error("WHS: INI section must be a string", 1);
}

if (!is_string(argument1)) {
   show_error("WHS: INI key must be a string", 1);
}

if (!ds_map_exists(global.whs_ini, argument0)) {
   show_error("WHS: You must join INI section before modifying it", 1);
}

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 3);
buffer_write(global.whs_writable, buffer_u8, 3);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_write(global.whs_writable, buffer_string, argument1);

if (is_string(argument2)) {
   buffer_write(global.whs_writable, buffer_u8, 1);
   buffer_write(global.whs_writable, buffer_string, argument2);
} else if (is_real(argument2)) {
   buffer_write(global.whs_writable, buffer_u8, 2);
   buffer_write(global.whs_writable, buffer_f64, argument2);
} else if (is_bool(argument2)) {
   buffer_write(global.whs_writable, buffer_u8, 3);
   buffer_write(global.whs_writable, buffer_bool, argument2);
} else {
   show_error("WHS: INI value can only be string, real or bool", 1);
}

buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

var section = ds_map_find_value(global.whs_ini, argument0);
ds_map_add(section, argument1, argument2);

#define whs_ini_read
/// whs_ini_read(section,key)
if (!is_string(argument0)) {
   show_error("WHS: INI section must be a string", 1);
}

if (!is_string(argument1)) {
   show_error("WHS: INI key must be a string", 1);
}

if (!ds_map_exists(global.whs_ini, argument0)) {
   show_error("WHS: You must join INI section before modifying it", 1);
}

var section = ds_map_find_value(global.whs_ini, argument0);
return ds_map_find_value(section, argument1);

#define whs_ini_ready
/// whs_ini_read(section)
if (!is_string(argument0)) {
   show_error("WHS: INI section must be a string", 1);
}

return ds_map_exists(global.whs_ini, argument0);

#define whs_on_connect
/// whs_on_connect(script)
if (!script_exists(argument0)) {
   show_error("WHS: Invalid callback script for connect callback", 1);
}

global.whs_callback_connect = argument0;

#define whs_on_account
/// whs_on_account(script)
if (!script_exists(argument0)) {
   show_error("WHS: Invalid callback script for account callback", 1);
}

global.whs_callback_account = argument0;

#define whs_on_session
/// whs_on_entered(script)
if (!script_exists(argument0)) {
   show_error("WHS: Invalid callback script for session callback", 1);
}

global.whs_callback_session = argument0;

#define whs_on_streams
/// whs_on_streams(script)
if (!script_exists(argument0)) {
   show_error("WHS: Invalid callback script for streams callback", 1);
}

global.whs_callback_streams = argument0;

#define whs_on_message
/// whs_on_message(script)
if (!script_exists(argument0)) {
   show_error("WHS: Invalid callback script for message callback", 1);
}

global.whs_callback_message = argument0;

#define whs_on_matches
/// whs_on_matches(script)
if (!script_exists(argument0)) {
   show_error("WHS: Invalid callback script for matches callback", 1);
}

global.whs_callback_matches = argument0;

#define whs_account_create
/// whs_account_create(username,password)
argument0 = string(argument0);
argument1 = string(argument1);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 4);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_write(global.whs_writable, buffer_string, argument1);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_account_login
/// whs_account_login(username,password)
argument0 = string(argument0);
argument1 = string(argument1);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 4);
buffer_write(global.whs_writable, buffer_u8, 2);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_write(global.whs_writable, buffer_string, argument1);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_account_change
/// whs_account_change(oldpassword,newpassword)
argument0 = string(argument0);
argument1 = string(argument1);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 4);
buffer_write(global.whs_writable, buffer_u8, 3);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_write(global.whs_writable, buffer_string, argument1);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_account_logout
/// whs_account_logout()
buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 4);
buffer_write(global.whs_writable, buffer_u8, 4);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_room_enter
/// whs_room_enter(name)
if (!is_string(argument0)) {
   show_error("WHS: Room name must be a string", 1);
}

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 5);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_room_leave
/// whs_room_leave()
buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 5);
buffer_write(global.whs_writable, buffer_u8, 2);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_room_ready
/// whs_room_ready()
if (global.whs_room = undefined) {
   return false;
} else {
   return true;
}

#define whs_room_name
/// whs_room_name()
return global.whs_room;

#define whs_player_create
/// whs_player_create(x,y)
buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 7);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_u16, x);
buffer_write(global.whs_writable, buffer_u16, y);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_player_update
/// whs_player_update(x,y)
if !(x = xprevious and y = yprevious) {
   buffer_seek(global.whs_writable, buffer_seek_start, 0);
   buffer_write(global.whs_writable, buffer_u16, 0);
   buffer_write(global.whs_writable, buffer_u16, 7);
   buffer_write(global.whs_writable, buffer_u8, 1);
   buffer_write(global.whs_writable, buffer_u16, x);
   buffer_write(global.whs_writable, buffer_u16, y);
   buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
   network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));
}

#define whs_player_destroy
/// whs_player_destroy()
buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 7);
buffer_write(global.whs_writable, buffer_u8, 2);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_other_bind
/// whs_other_bind(object)
if (!object_exists(argument0)) {
   show_error("WHS: Invalid object for other player", 1);
}

global.whs_other_player = argument0;

#define whs_other_smooth
/// whs_other_smooth(percentage)
if (!is_real(argument0)) {
   show_error("WHS: Other player smoothening should be a number", 1);
}

if !(1 <= argument0 && argument0 <= 100) {
   show_error("WHS: Other player smoothening can only be 1-100", 1);
}

global.whs_other_delays = 100 - argument0;

#define whs_other_create
/// whs_other_create()
whs_x = x;
whs_y = y;

#define whs_other_update
/// whs_other_update(smooth)
x = lerp(x, whs_x, global.whs_other_delays/100);
y = lerp(y, whs_y, global.whs_other_delays/100);

#define whs_other_destroy
/// whs_other_destroy()

#define whs_other_index
/// whs_other_index(instance)
if (instance_exists(argument0)) {
   var key = ds_map_find_first(global.whs_all);
   while (key != undefined) {
      var instance = ds_map_find_value(global.whs_all, key);
      if (instance = argument0) {
         return real(key);
      }
      key = ds_map_find_next(global.whs_all, key);
   }
}

return undefined;

#define whs_other_count
/// whs_other_count()
return ds_map_size(global.whs_all);

#define whs_object_create
/// whs_object_create(id)
if (!instance_exists(argument0)) {
   show_error("WHS: Native instance must exist before creating WHS instance", 1);
}

if (global.whs_room = undefined) {
   return false;
}

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 8);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_u16, argument0);
buffer_write(global.whs_writable, buffer_u16, (argument0).x);
buffer_write(global.whs_writable, buffer_u16, (argument0).y);
buffer_write(global.whs_writable, buffer_u16, (argument0).object_index);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_object_update
/// whs_object_update(id)
if (global.whs_room = undefined) {
   return false;
}

if !(x = xprevious and y = yprevious) {
   buffer_seek(global.whs_writable, buffer_seek_start, 0);
   buffer_write(global.whs_writable, buffer_u16, 0);
   buffer_write(global.whs_writable, buffer_u16, 8);
   buffer_write(global.whs_writable, buffer_u8, 2);
   buffer_write(global.whs_writable, buffer_u16, argument0);
   buffer_write(global.whs_writable, buffer_u16, (argument0).x);
   buffer_write(global.whs_writable, buffer_u16, (argument0).y);
   buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
   network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));
}

#define whs_object_destroy
/// whs_object_destroy(id)
if (global.whs_room = undefined) {
   return false;
}

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 8);
buffer_write(global.whs_writable, buffer_u8, 3);
buffer_write(global.whs_writable, buffer_u16, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_object_count
/// whs_object_count()
return ds_map_size(global.whs_obj);

#define whs_writable_togame
/// whs_writable_togame()
var stream = buffer_create(1, buffer_grow, 1);
buffer_seek(stream, buffer_seek_start, 0);
buffer_write(stream, buffer_u16, 0);
buffer_write(stream, buffer_u16, 9);
buffer_write(stream, buffer_u8, 1);
return stream;

#define whs_writable_toroom
/// whs_writable_toroom()
var stream = buffer_create(1, buffer_grow, 1);
buffer_seek(stream, buffer_seek_start, 0);
buffer_write(stream, buffer_u16, 0);
buffer_write(stream, buffer_u16, 9);
buffer_write(stream, buffer_u8, 2);
return stream;

#define whs_writable_touser
/// whs_writable_touser(username)
var stream = buffer_create(1, buffer_grow, 1);
buffer_seek(stream, buffer_seek_start, 0);
buffer_write(stream, buffer_u16, 0);
buffer_write(stream, buffer_u16, 9);
buffer_write(stream, buffer_u8, 3);
buffer_write(stream, buffer_string, argument0);
return stream;

#define whs_writable_type
/// whs_writable_type(stream,value)
if (!is_real(argument1)) {
   show_error("WHS: Writable stream type expects a number", 1);
}

buffer_write(argument0, buffer_u16, argument1);

#define whs_writable_string
/// whs_writable_string(stream,value)
if (!is_string(argument1)) {
   show_error("WHS: Writable stream string expects a string", 1);
}

buffer_write(argument0, buffer_string, argument1);

#define whs_writable_number
/// whs_writable_number(stream,value)
if (!is_real(argument1)) {
   show_error("WHS: Writable stream number expects a number", 1);
}

buffer_write(argument0, buffer_f64, argument1);

#define whs_writable_bool
/// whs_writable_bool(stream,value)
if (!is_real(argument1)) {
   show_error("WHS: Writable stream bool expects a boolean", 1);
}

buffer_write(argument0, buffer_bool, argument1);

#define whs_writable_end
/// whs_writable_end(stream)
var stream = argument0;
buffer_poke(stream, 0, buffer_u16, buffer_tell(stream));
network_send_raw(global.whs_socket, stream, buffer_tell(stream));
buffer_delete(stream);

#define whs_readable_type
/// whs_readable_type(stream)
if (buffer_get_size(argument0) > buffer_tell(argument0)) {
   return buffer_read(argument0, buffer_u16);
} else {
   show_error("WHS: The readable stream has nothing left to read", 1);
}

#define whs_readable_string
/// whs_readable_string(stream)
if (buffer_get_size(argument0) > buffer_tell(argument0)) {
   return buffer_read(argument0, buffer_string);
} else {
   show_error("WHS: The readable stream has nothing left to read", 1);
}

#define whs_readable_number
/// whs_readable_number(stream)
if (buffer_get_size(argument0) > buffer_tell(argument0)) {
   return buffer_read(argument0, buffer_f64);
} else {
   show_error("WHS: The readable stream has nothing left to read", 1);
}

#define whs_readable_bool
/// whs_readable_bool(stream)
if (buffer_get_size(argument0) > buffer_tell(argument0)) {
   return buffer_read(argument0, buffer_bool);
} else {
   show_error("WHS: The readable stream has nothing left to read", 1);
}

#define whs_readable_end
/// whs_readable_end(stream)
buffer_delete(argument0);

#define whs_message_togame
/// whs_message_togame(message)
argument0 = string(argument0);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 10);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_message_toroom
/// whs_message_toroom(message)
argument0 = string(argument0);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 10);
buffer_write(global.whs_writable, buffer_u8, 2);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_message_touser
/// whs_message_touser(message,username)
argument0 = string(argument0);
argument1 = string(argument1);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 10);
buffer_write(global.whs_writable, buffer_u8, 3);
buffer_write(global.whs_writable, buffer_string, argument0);
buffer_write(global.whs_writable, buffer_string, argument1);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_message_format_game
/// whs_message_format_game(string)
if (!is_string(argument0)) {
   show_error("WHS: Message format must be a string", 1);
}

global.whs_format_game = argument0;

#define whs_message_format_room
/// whs_message_format_room(string)
if (!is_string(argument0)) {
   show_error("WHS: Message format must be a string", 1);
}

global.whs_format_room = argument0;

#define whs_message_format_user
/// whs_message_format_user(string)
if (!is_string(argument0)) {
   show_error("WHS: Message format must be a string", 1);
}

global.whs_format_user = argument0;

#define whs_match_find
/// whs_match_find(channel)
if (!is_real(argument0)) {
   show_error("WHS: Match channel must be a number", 1);
}

argument0 = clamp(argument0, 0, 65535);

buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 11);
buffer_write(global.whs_writable, buffer_u8, 1);
buffer_write(global.whs_writable, buffer_u16, argument0);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

#define whs_match_stop
/// whs_match_stop()
buffer_seek(global.whs_writable, buffer_seek_start, 0);
buffer_write(global.whs_writable, buffer_u16, 0);
buffer_write(global.whs_writable, buffer_u16, 11);
buffer_write(global.whs_writable, buffer_u8, 2);
buffer_poke(global.whs_writable, 0, buffer_u16, buffer_tell(global.whs_writable));
network_send_raw(global.whs_socket, global.whs_writable, buffer_tell(global.whs_writable));

