// Copyright 2024 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

test "new" {
  let queue : Queue[Int] = new()
  @assertion.assert_eq(queue.length, 0)?
}

test "from_array_1" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  let queue2 : Queue[Int] = Queue::[1]
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.pop_exn(), 2)?
  @assertion.assert_eq(queue.pop_exn(), 3)?
  @assertion.assert_eq(queue.pop_exn(), 4)?
  @assertion.assert_eq(queue2.pop_exn(), 1)?
  @assertion.assert_eq(queue2.length, 0)?
}

test "from_array_2" {
  let q = Queue::[1, 2, 3, 4]
  q.push(11)
  @assertion.assert_eq(q, Queue::[1, 2, 3, 4, 11])?
  q.pop_exn() |> ignore
  @assertion.assert_eq(q, Queue::[2, 3, 4, 11])?
}

test "from_array_3" {
  let q : Queue[Int] = Queue::[]
  inspect(q, content="Queue::[]")?
}

test "to_string" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  inspect(queue, content="Queue::[1, 2, 3, 4]")?
  queue.push(11)
  inspect(queue, content="Queue::[1, 2, 3, 4, 11]")?
  queue.pop_exn() |> ignore
  inspect(queue, content="Queue::[2, 3, 4, 11]")?
}

test "op_equal" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  let queue2 : Queue[Int] = Queue::[1, 2, 3, 4]
  let queue3 : Queue[Int] = Queue::[1, 2, 3, 5]
  @assertion.assert_true(queue == queue2)?
  @assertion.assert_false(queue == queue3)?
  queue.pop_exn() |> ignore
  @assertion.assert_false(queue == queue2)?
  @assertion.assert_eq(queue, Queue::[2, 3, 4])?
}

test "clear" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.length, 4)?
  queue.clear()
  @assertion.assert_eq(queue.length, 0)?
}

test "is_empty" {
  let queue : Queue[Int] = new()
  @assertion.assert_true(queue.is_empty())?
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(4)
  @assertion.assert_false(queue.is_empty())?
}

test "push" {
  let queue : Queue[Int] = Queue::new()
  queue.push(1)
  queue.push(2)
  queue.push(3)
  queue.push(1)
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue, Queue::[1, 2, 3, 1])?
}

test "peek_exn" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.peek_exn(), 1)?
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.peek_exn(), 2)?
  @assertion.assert_eq(queue.length, 3)?
}

test "peek" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.peek(), Some(1))?
  queue.clear()
  @assertion.assert_eq(queue.peek(), None)?
}

test "pop_exn" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.pop_exn(), 1)?
  @assertion.assert_eq(queue.pop_exn(), 2)?
  @assertion.assert_eq(queue.pop_exn(), 3)?
  @assertion.assert_eq(queue.pop_exn(), 4)?
  @assertion.assert_eq(queue.length, 0)?
}

test "pop" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  @assertion.assert_eq(queue.pop(), Some(1))?
  @assertion.assert_eq(queue.pop(), Some(2))?
  @assertion.assert_eq(queue.pop(), Some(3))?
  @assertion.assert_eq(queue.pop(), Some(4))?
  @assertion.assert_eq(queue.pop(), None)?
}

test "iter" {
  let queue : Queue[Int] = new()
  let mut sum = 0
  queue.iter(fn(x) { sum = sum + x })
  @assertion.assert_eq(sum, 0)?
  Queue::[1, 2, 3, 4].transfer(queue)
  sum = 0
  queue.iter(fn(x) { sum = sum + x })
  @assertion.assert_eq(sum, 10)?
}

test "iteri" {
  let queue : Queue[Int] = new()
  let mut sum = 0
  queue.iteri(fn(x, i) { sum = sum + x * i })
  @assertion.assert_eq(sum, 0)?
  Queue::[1, 2, 3, 4].transfer(queue)
  sum = 0
  queue.iteri(fn(x, i) { sum = sum + x * i })
  @assertion.assert_eq(sum, 20)?
}

test "fold" {
  let queue : Queue[Int] = new()
  let sum = queue.fold(init=0, fn(acc, x) { acc + x })
  @assertion.assert_eq(sum, 0)?
  Queue::[1, 2, 3, 4].transfer(queue)
  let sum = queue.fold(init=0, fn(acc, x) { acc + x })
  @assertion.assert_eq(sum, 10)?
  let sum2 = Queue::[1, 2, 3, 4].fold(init=0, fn(acc, x) { acc + x })
  @assertion.assert_eq(sum2, 10)?
}

test "copy" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  let queue2 : Queue[Int] = queue.copy()
  @assertion.assert_eq(queue2.length, 4)?
  @assertion.assert_eq(queue2, Queue::[1, 2, 3, 4])?
  @assertion.assert_eq(queue.length, 4)?
  @assertion.assert_eq(queue, Queue::[1, 2, 3, 4])?
}

test "transfer" {
  let queue : Queue[Int] = Queue::[1, 2, 3, 4]
  let queue2 : Queue[Int] = Queue::[5, 6, 7, 8]
  queue.transfer(queue2)
  @assertion.assert_eq(queue.length, 0)?
  @assertion.assert_eq(queue2.length, 8)?
  @assertion.assert_eq(queue2, Queue::[5, 6, 7, 8, 1, 2, 3, 4])?
}

test "cell_equal" {
  @assertion.assert_false(Queue::[].first == Queue::[1].first)?
}

test "length" {
  let empty : Queue[Unit] = Queue::[]
  inspect(empty.length(), content="0")?
  inspect(Queue::[1, 2, 3].length(), content="3")?
}

test "as_iter" {
  let q = Queue::[1, 2, 3, 4, 5]
  inspect(q.as_iter().fold(fn(x, y) { x + y }, 0), content="15")?
}
