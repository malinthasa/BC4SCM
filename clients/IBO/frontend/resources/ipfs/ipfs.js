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
  const doc = document.getElementById("doc");
  reader.readAsArrayBuffer(doc.files[0]); // Read Provided File
}

function CatFile() {
  var ipfsPath = prompt("Welcome to GetFile, please provide the file hash");
  //ipfsPath = "QmUBEMeHziqDPRfPerKLz9T2YPTFdMcKTn6rwiuPwBGi81";
  ipfs.cat(ipfsPath, function(err, file) {
    if (err) {
      throw err;
    }
    console.log(file.toString("utf8"));
    doc = file.toString("base64");
    alert("The file is : " + file.toString("utf8"));
    document.getElementById("design_display").src =
      "data:image/png;base64," + img;
  });
  const log = line => {
    document
      .getElementById("output")
      .appendChild(document.createTextNode(`${line}\r\n`));
  };
}

function GetFile() {
  var FileHash = prompt("Welcome to GetFile, please provide the file hash");
  //const FileHash = "QmUBEMeHziqDPRfPerKLz9T2YPTFdMcKTn6rwiuPwBGi81";
  ipfs.get(FileHash, function(err, files) {
    files.forEach(file => {
      console.log("the path is : " + file.path);
      console.log(file.content.toString("utf8"));
      alert("the path is : " + file.path);
      alert("File Contents : " + file.content.toString("utf8"));

    });
  });
}

function loadImage() {
  var input, file, fr;

  input = document.getElementById("inputtext").value;

  //IPFS START
  const repoPath = "ipfs-1111"; //+ Math.random()
  const ipfs = new Ipfs({ repo: repoPath });

  ipfs.on("ready", () => {
    ipfsPath = input;
    ipfs.files.cat(ipfsPath, function(err, file) {
      if (err) {
        throw err;
      }
      img = file.toString("base64");
      document.getElementById("design_display").src =
        "data:image/png;base64," + img;
    });

    const log = line => {
      document
        .getElementById("output")
        .appendChild(document.createTextNode(`${line}\r\n`));
    };
  });
}
