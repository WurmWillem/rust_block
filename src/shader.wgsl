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

struct Sphere {
    pos: vec3f,
    radius: f32,
    color: vec3f,
}

// Fragment shader
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let width = in.win_size.x;
    let height = in.win_size.y;

    let aspect_ratio = width / height;
    let view_height = 2.;
    let view_width = view_height * aspect_ratio;

    let focal_length = 1.;
    let cam_center = vec3f(in.cam_pos.xy, 0.);

    let view_u = vec3f(view_width, 0., 0.);
    let view_v = vec3f(0., -view_height, 0.);

    let delta_u = view_u / width;
    let delta_v = view_v / height;

    let d = -0.5 * (view_v + view_u);
    let view_upper_left = cam_center - vec3f(0., 0., focal_length) + d;
    let upper_left_pix = view_upper_left + 0.5 * (delta_u + delta_v);

    let pix_center = upper_left_pix + in.clip_position.x * delta_u + in.clip_position.y * delta_v;

    var ray: Ray;
    ray.orig = cam_center;
    ray.dir = pix_center - cam_center;
    let color = ray_color(ray);

    return vec4<f32>(color, 1.0);
    // return vec4<f32>(800. / width, 800. / width, 800. / width, 1.0);
}

fn ray_color(ray: Ray) -> vec3f {
    let sphere = Sphere(vec3f(0.,0.,-1.), 0.5, vec3f(1., 0., 0.));

    if (hit_sphere(sphere, ray)) {
        return sphere.color;
    }

    let unit_dir = normalize(ray.dir);
    let a = 2. * (unit_dir.y + 1.);
    // return vec4<f32>(0., 0., 0.3, 1.0);
    return ((1. - a) * vec3f(1.) + a * vec3f(0.5, 0.7, 1.));
}

fn hit_sphere(s: Sphere, r: Ray) -> bool {
    let oc = r.orig - s.pos;
    let a = dot(r.dir, r.dir);
    let b = 2.0 * dot(oc, r.dir);
    let c = dot(oc, oc) - s.radius*s.radius;
    let discriminant = b*b - 4. * a*c;
    return discriminant >= 0.;
}