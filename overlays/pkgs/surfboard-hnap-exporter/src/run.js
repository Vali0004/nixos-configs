#!/run/current-system/sw/bin/env node
const SurfboardHNAP = require("./modem");

const modem = new SurfboardHNAP({ host: "192.168.100.1" });

const username = process.env.USERNAME || "admin";
const password = process.env.PASSWORD; // default is last 8 of serial, per the page
if (!password)
  throw new Error("Set PASSWORD env var.");

const login = await modem.login({ username, password });
console.log("LoginResult:", login.result);

const r = await modem.hnap("GetMultipleHNAPs", {
  GetCustomerStatusDownstreamChannelInfo: "",
  GetCustomerStatusUpstreamChannelInfo: "",
});

function parseDownstream(str) {
  // DS: ch^lock^mod^chanId^freqHz^powerdBmV^snrDb^corr^uncorr^
  return str
    .split("|+|")
    .filter(Boolean)
    .map((row) => row.replace(/\^$/, "")) // sometimes trailing ^
    .map((row) => {
      const [ch, lock, mod, chanId, freq, power, snr, corr, uncorr] = row.split("^");
      return {
        ch: Number(ch),
        lock,
        modulation: mod,
        channelId: Number(chanId),
        frequencyHz: Number(freq),
        powerdBmV: Number(power),
        snrDb: Number(snr),
        corrected: Number(corr),
        uncorrectable: Number(uncorr),
      };
    });
}

function parseUpstream(str) {
  // US: ch^lock^mod^chanId^widthHz^freqHz^powerdBmV^
  return str
    .split("|+|")
    .filter(Boolean)
    .map((row) => row.replace(/\^$/, ""))
    .map((row) => {
      const [ch, lock, mod, chanId, width, freq, power] = row.split("^");
      return {
        ch: Number(ch),
        lock,
        modulation: mod,
        channelId: Number(chanId),
        channelWidthHz: Number(width),
        frequencyHz: Number(freq),
        powerdBmV: Number(power),
      };
    });
}

const resp = r.json;

const dsStr =
  resp.GetMultipleHNAPsResponse.GetCustomerStatusDownstreamChannelInfoResponse.CustomerConnDownstreamChannel;

const usStr =
  resp.GetMultipleHNAPsResponse.GetCustomerStatusUpstreamChannelInfoResponse.CustomerConnUpstreamChannel;

const ds = parseDownstream(dsStr);
const us = parseUpstream(usStr);
console.table(ds);
console.table(us);