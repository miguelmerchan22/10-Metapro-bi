const proxy = "https://proxy-sites.herokuapp.com/";

const PRE = "https://precio-site.herokuapp.com/api/v1/servicio/precio/v2/SITE";

const WS = "0x0000000000000000000000000000000000000000";//0x0000000000000000000000000000000000000000 recibe los huerfanos por defecto

var SC = "0xaD356cA07BE4A9a3237b7d4326ad07D08846fb60";// direccion del contrato V1
var SC2 = "0xaD356cA07BE4A9a3237b7d4326ad07D08846fb60";// direccion del contrato V2

var TOKEN = "0x55d398326f99059fF775485246999027B3197955";

if(true){// activar testnet
    SC =  "0xe9811A48100C136F8D3a272849eB7687073981f8";// contrato testent
    SC2 =  "0xe9811A48100C136F8D3a272849eB7687073981f8";// contrato testent
    TOKEN = "0xd5881b890b443be0c609BDFAdE3D8cE886cF9BAc";

}



export default {proxy, WS, SC, SC2, PRE, TOKEN};
