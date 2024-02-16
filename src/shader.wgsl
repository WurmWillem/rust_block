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

@group(0) @binding(0) 
var<uniform> uni: Uniform;

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

// Fragment shader
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let win_width = in.win_size.x;
    let win_height = in.win_size.y;

    let aspect_ratio = win_width / win_height;
    let view_height = win_height;
    let view_width = view_height * aspect_ratio;

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
    // return vec4<f32>(0.99, 0., 0., 1.0);
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