const proxy = "https://proxy-sites.herokuapp.com/";

const PRE = "https://precio-site.herokuapp.com/api/v1/servicio/precio/v2/SITE";

const WS = "0x0000000000000000000000000000000000000000";//0x0000000000000000000000000000000000000000 recibe los huerfanos por defecto

var SC = "0xaD356cA07BE4A9a3237b7d4326ad07D08846fb60";// direccion del contrato V1
var TOKEN = "0x55d398326f99059fF775485246999027B3197955";

var SCtest = "0x9eCabcbef6050B5c1F1b0061Cadc59d7FbfdE43e";// direccion del contrato de pruebas test only no real
var TOKENtest = "0xd5881b890b443be0c609BDFAdE3D8cE886cF9BAc";


var testnet = true;


export default {proxy, WS, SCtest, TOKENtest, SC, PRE, TOKEN, testnet};
