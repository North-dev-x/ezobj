use std::time::Instant;
use rand::prelude::*;
use uuid::Uuid;

#[derive(Debug)]
struct TestingStruct {
  value: i16,
  id: Uuid,
}

impl TestingStruct {
  fn method(&self) -> String {
    self.value.to_string() + &self.id.to_string()
  }
}

fn main() {
  let now = Instant::now();
  let mut instances: Vec<String> = Vec::new();
  for _ in 1..=10000 {
    instances.push(TestingStruct {
      value: random(),
      id: Uuid::new_v4(),
    }.method());
  }

  let elapsed = now.elapsed();
  println!("{:?}",instances);
  println!("Elapsed: {:.2?}", elapsed);

}


