const ipfs = new Ipfs({ start: false });

ipfs.on("ready", () => {
  console.log("Ipfs node is ready to use!");
  ipfs.start();
});
ipfs.on("error", error => {
  console.error("Something went  wrong!", error);
});

function upload() {
  const reader = new FileReader();
  reader.onloadend = function() {
    const buf = Ipfs.Buffer(reader.result); // Convert data into buffer
    ipfs.add(buf, (err, result) => {
      // Upload buffer to IPFS
      if (err) {
        console.error(err);
        return;
      }
      let url = `https://ipfs.io/ipfs/${result[0].hash}`;
      console.log(`Url --> ${url}`);
      document.getElementById("url").innerHTML = url;
      document.getElementById("url").href = url;
      document.getElementById("output").src = url;
    });
  };
//  const doc = document.getElementById("doc");
//  reader.readAsArrayBuffer(doc.files[0]);
}