#[repr(C)]
#[derive(Debug, Copy, Clone, bytemuck::Pod, bytemuck::Zeroable)]
pub struct Uniform {
    pub cam_pos: [f32; 3],
    pub win_size: [f32; 2],
}

#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
pub struct Vertex {
    position: [f32; 3],
    color: [f32; 3],
}
impl Vertex {
    pub fn desc() -> wgpu::VertexBufferLayout<'static> {
        wgpu::VertexBufferLayout {
            array_stride: std::mem::size_of::<Vertex>() as wgpu::BufferAddress,
            step_mode: wgpu::VertexStepMode::Vertex,
            attributes: &[
                wgpu::VertexAttribute {
                    offset: 0,
                    shader_location: 0,
                    format: wgpu::VertexFormat::Float32x3,
                },
                wgpu::VertexAttribute {
                    offset: std::mem::size_of::<[f32; 3]>() as wgpu::BufferAddress,
                    shader_location: 1,
                    format: wgpu::VertexFormat::Float32x3,
                },
            ],
        }
    }
}

pub struct Input {
    pub a: bool,
    pub d: bool,
    pub w: bool,
    pub s: bool,
    pub space: bool,
    pub shift: bool,
    pub c: bool,
}
impl Input {
    pub fn new() -> Input {
        Input {
            a: false,
            d: false,
            w: false,
            s: false,
            space: false,
            shift: false,
            c: false,
        }
    }
}

pub const VERTICES: &[Vertex] = &[
    Vertex {
        position: [-1.0, 1., 0.0],
        color: [1.0, 0.0, 0.0],
    },
    Vertex {
        position: [-1., -1., 0.0],
        color: [0.0, 1.0, 0.0],
    },
    Vertex {
        position: [1., -1., 0.0],
        color: [0.0, 0.0, 1.0],
    },
    Vertex {
        position: [1., -1., 0.0],
        color: [0.0, 0.0, 1.0],
    },
    Vertex {
        position: [1., 1., 0.0],
        color: [0.0, 1.0, 0.0],
    },
    Vertex {
        position: [-1.0, 1., 0.0],
        color: [1.0, 0.0, 0.0],
    },
];
