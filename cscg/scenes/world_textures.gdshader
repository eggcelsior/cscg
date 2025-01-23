shader_type spatial;

uniform sampler2D grass_texture;
uniform sampler2D rock_texture;
uniform sampler2D dirt_texture;
uniform float min_rock_slope : hint_range(0.0, 1.0) = 0.5;
uniform float max_grass_slope : hint_range(0.0, 1.0) = 0.9;
uniform float min_rockgrass_height = -8.0;
uniform float max_dirt_height = -6.0;
uniform float texture_scale = 4.0;
uniform float blend_sharpness = 8.0;

varying vec3 world_pos;
varying vec3 world_normal;
varying float vertex_y;

void vertex() {
    // Get world position and normal for triplanar mapping
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    vertex_y = VERTEX.y;
}

vec3 triplanar_texture(sampler2D tex, vec3 world_position, vec3 blend) {
    vec3 x_tex = texture(tex, world_position.zy * texture_scale).rgb;
    vec3 y_tex = texture(tex, world_position.xz * texture_scale).rgb;
    vec3 z_tex = texture(tex, world_position.xy * texture_scale).rgb;
    
    return x_tex * blend.x + y_tex * blend.y + z_tex * blend.z;
}

void fragment() {
    // Calculate triplanar blend weights
    vec3 blend_weights = abs(world_normal);
    blend_weights = pow(blend_weights, vec3(blend_sharpness));
    blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);
    
    // Sample textures using triplanar mapping
    vec3 grass_albedo = triplanar_texture(grass_texture, world_pos, blend_weights);
    vec3 rock_albedo = triplanar_texture(rock_texture, world_pos, blend_weights);
    vec3 dirt_albedo = triplanar_texture(dirt_texture, world_pos, blend_weights);
    
    // Calculate slope-based blending
    float rock_grass_weight = world_normal.y;
    float dirt_rockgrass_weight = vertex_y;
    
    // Slope blend between rock and grass
    rock_grass_weight = max(min_rock_slope, rock_grass_weight);
    rock_grass_weight = min(max_grass_slope, rock_grass_weight);
    rock_grass_weight -= min_rock_slope;
    rock_grass_weight /= max_grass_slope - min_rock_slope;
    
    // Height blend for dirt
    dirt_rockgrass_weight = max(min_rockgrass_height, dirt_rockgrass_weight);
    dirt_rockgrass_weight = min(max_dirt_height, dirt_rockgrass_weight);
    dirt_rockgrass_weight -= min_rockgrass_height;
    dirt_rockgrass_weight /= max_dirt_height - min_rockgrass_height;
    
    // Final blending
    vec3 rockgrass_albedo = mix(rock_albedo, grass_albedo, rock_grass_weight);
    ALBEDO = mix(dirt_albedo, rockgrass_albedo, dirt_rockgrass_weight);
}