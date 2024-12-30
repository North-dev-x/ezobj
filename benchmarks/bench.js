class TestingClass {
  constructor(value, id) {
    this.value = value;
    this.id = id;
  }
  method = function() {
    return toString(this.value) + this.id;
  }
}

function getRandomIntInclusive(min, max) {
  const minCeiled = Math.ceil(min);
  const maxFloored = Math.floor(max);
  return Math.floor(Math.random() * (maxFloored - minCeiled + 1) + minCeiled); 
}

function uuidv4() {
  return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
    (+c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> +c / 4).toString(16)
  );
}

function main() {
  let now =  performance.now();
  let instances = [];
  for (let i = 0; i <= 10000; i++) {
    instances.push(new TestingClass(getRandomIntInclusive(-20000,20000), uuidv4()).method());
  }
  let endtime = performance.now() - now;
  console.log("Elapsed: " + endtime + "ms")
}

main()
