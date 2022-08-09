import express from "express";
import { PORT } from "./constants";
import { decodeData, initDecoder } from "./decoder";

const app = express();

app.use(express.json());

initDecoder();

app.get("/", (req, res) => {
  res.send("ok");
});

app.post("/", (req, res) => {
  const data = decodeData(req.body.data);
  res.send({ data});
});

app.listen(PORT);
