// Vertex shader

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec3<f32>,
}

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(1) pos: vec3<f32>,
    @location(2) cam_pos: vec2f,
    @location(3) win_size: vec2f,
};

struct Uniform {
    cam_pos: vec2f,
    win_size: vec2f,
}

@group(0) @binding(0) var<uniform> uni: Uniform;

@vertex
fn vs_main(
    vert: VertexInput
) -> VertexOutput {
    var out: VertexOutput;
    // out.color = vert.color;
    out.pos = vert.position;
    out.clip_position = vec4<f32>(vert.position, 1.0);
    out.cam_pos = uni.cam_pos.xy;
    out.win_size = uni.win_size.xy;
    // out = vec4<f32>(vert.position, 1.0);
    return out;
}

struct Ray {
    orig: vec3<f32>,
    dir: vec3<f32>,
}
fn ray_at(ray: Ray, t: f32) -> vec3f {
    return ray.orig + t * ray.dir;
}

struct Sphere {
    pos: vec3f,
    radius: f32,
    color: vec3f,
}

const O = vec3f(0.);                           
const DIST_FROM_VIEW = 1.;

const MAX_T = 100000000000000000000000000000000000000.;

const SPHERE_AMT = 3; 

// computes intersection of ray with every object, and returns color of closest
fn trace_ray(dir: vec3f) -> vec3f {
    var closest_t = MAX_T;
    var spheres = array(
        Sphere(vec3f(2.,0.,4.), 1., vec3f(0., 1., 0.)),
        Sphere(vec3f(0.,1.,3.), 1., vec3f(1., 0., 0.)),
        Sphere(vec3f(-2.,0., 4.), 1., vec3f(0., 0., 1.)),
        );

    var closest_sphere_index = -1;

    for (var i = 0; i < SPHERE_AMT; i += 1) {
        
        let intersections = intersect_ray_sphere(dir, spheres[i]);
        
        let t1 = intersections.x;
        let t2 = intersections.y;
        if t1 == MAX_T {
            // return vec3f(0., 0., 0.);
        }
        if t1 >= DIST_FROM_VIEW && t1 < MAX_T && t1 < closest_t {
            closest_t = t1;
            closest_sphere_index = i32(i);
        }
        if t2 > DIST_FROM_VIEW && t2 < MAX_T && t2 < closest_t {
            closest_t = t2;
            closest_sphere_index = i32(i);
        }
    }

    if closest_sphere_index >= 0 {
        return spheres[closest_sphere_index].color;
    } 

    let unit_dir = normalize(dir);
    let a = 1. * (unit_dir.y + 1.);
    // return vec4<f32>(0., 0., 0.3, 1.0);
    return ((1. - a) * vec3f(1.) + a * vec3f(0.5, 0.7, 1.));
}

fn intersect_ray_sphere(dir: vec3f, sphere: Sphere) -> vec2f {
    let CO = O - sphere.pos;

    let a = dot(dir, dir);
    let b = 2.*dot(CO, dir);
    let c = dot(CO, CO) - sphere.radius*sphere.radius;

    let discriminant = b*b - 4.*a*c;
    if discriminant < 0. {
        return vec2f(MAX_T, MAX_T);
    }

    let t1 = (-b + sqrt(discriminant)) / (2.*a);
    let t2 = (-b - sqrt(discriminant)) / (2.*a);
    return vec2f(t1, t2);
}

// Fragment shader
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let win_width = in.win_size.x;
    let win_height = in.win_size.y;

    let aspect_ratio = win_width / win_height;
    let view_height = 1.;
    let view_width = view_height * aspect_ratio;

    let focal_length = sqrt(view_width * view_width + view_height * view_height);

    let x_win = in.clip_position.x + in.cam_pos.x - win_width * 0.5;
    let y_win = in.clip_position.y + in.cam_pos.y - win_height * 0.5;
    let view_coords = vec2f(
        x_win * view_width / win_width,
        y_win * view_height / win_height, 
    );

    let ray_dir = vec3f(view_coords.xy, DIST_FROM_VIEW);

    let color = trace_ray(ray_dir);
    return vec4<f32>(color, 1.0);
    // return vec4<f32>(in.clip_position.x, 0., 0., 1.0);
    /*

    // let focal_length = 1.;
    let focal_length = sqrt(view_width * view_width + view_height * view_height) / 1.1157034787; // / 2*tan(45/2)
    let cam_center = vec3f(in.cam_pos.xy, 0.);
    // let cam_center = vec3f(in.cam_pos.x + view_width * 0.5, in.cam_pos.y + view_height * 0.5, 0.);

    let view_u = vec3f(view_width, 0., 0.);
    let view_v = vec3f(0., -view_height, 0.);

    let delta_u = view_u / win_width;
    let delta_v = view_v / win_height;

    let d = -0.5 * (view_v + view_u);
    let view_upper_left = cam_center - vec3f(0., 0., focal_length) + d;
    let upper_left_pix = view_upper_left + 0.5 * (delta_u + delta_v);

    let pix_center = upper_left_pix + in.clip_position.x * delta_u + in.clip_position.y * delta_v;

    let ray = Ray(cam_center, pix_center - cam_center);
    let color = get_ray_color(ray);

    return vec4<f32>(color, 1.0);
    // return vec4<f32>(0.99, 0., 0., 1.0);*/
}

fn get_ray_color(ray: Ray) -> vec3f {
    let sphere = Sphere(vec3f(0.,0.,-1.), 0.2, vec3f(1., 0., 0.));

    let t = hit_sphere(sphere, ray);
    if t > 0. {
        let n = normalize(ray_at(ray, t) - sphere.pos);
        return 0.5*(n+1.);
    }

    let unit_dir = normalize(ray.dir);
    let a = 3. * (unit_dir.y + 1.);
    // return vec4<f32>(0., 0., 0.3, 1.0);
    return ((1. - a) * vec3f(1.) + a * vec3f(0.5, 0.7, 1.));
}

fn hit_sphere(s: Sphere, r: Ray) -> f32 {
    let oc = r.orig - s.pos;
    let a = dot(r.dir, r.dir);
    let half_b = dot(oc, r.dir);
    let c = dot(oc, oc) - s.radius*s.radius;
    let discriminant = half_b*half_b - a*c;

    if discriminant < 0. {
        return -1.;
    } 
    return (-half_b - sqrt(discriminant) ) / a;
    // return discriminant >= 0.;
}