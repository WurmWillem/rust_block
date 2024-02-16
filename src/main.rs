use rust_block::run;

fn main() {
    pollster::block_on(run());
}
