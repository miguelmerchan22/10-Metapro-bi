pragma solidity >=0.8.0;
// SPDX-License-Identifier: Apache-2.0

interface TRC20_Interface {

    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
    function transfer(address direccion, uint cantidad) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function decimals() external view returns(uint);
}

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        uint c = a - b;

        return c;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);

        return c;
    }

}

contract Context {

  constructor () { }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
  address payable public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor(){
    owner = payable(_msgSender());
  }
  modifier onlyOwner() {
    if(_msgSender() != owner)revert();
    _;
  }
  function transferOwnership(address payable newOwner) public onlyOwner {
    if(newOwner == address(0))revert();
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Admin is Context, Ownable{
  mapping (address => bool) public admin;

  event NewAdmin(address indexed admin);
  event AdminRemoved(address indexed admin);

  constructor(){
    admin[_msgSender()] = true;
  }

  modifier onlyAdmin() {
    if(!admin[_msgSender()])revert();
    _;
  }

  function makeNewAdmin(address payable _newadmin) public onlyOwner {
    if(_newadmin == address(0))revert();
    emit NewAdmin(_newadmin);
    admin[_newadmin] = true;
  }

  function makeRemoveAdmin(address payable _oldadmin) public onlyOwner {
    if(_oldadmin == address(0))revert();
    emit AdminRemoved(_oldadmin);
    admin[_oldadmin] = false;
  }

}

contract BinarySystem is Context, Admin{
  using SafeMath for uint256;

  address token = 0x55d398326f99059fF775485246999027B3197955;

  TRC20_Interface USDT_Contract = TRC20_Interface(token);

  struct Hand {
    uint256 lReclamados;
    uint256 lExtra;
    address lReferer;
    uint256 rReclamados;
    uint256 rExtra;
    address rReferer;
  }

  struct Deposito {
    uint256 inicio;
    uint256 amount;
    bool pasivo;
  }

  struct Investor {
    bool registered;
    uint256 balanceRef;
    uint256 balanceSal;
    uint256 totalRef;
    uint256 invested;
    uint256 paidAt;
    uint256 amount;
    uint256 withdrawn;
    uint256 directos;
    Deposito[] depositos;
    Hand hands;
  }

  uint256 public MIN_RETIRO = 30*10**18;
  uint256 public MIN_RETIRO_interno;

  uint256 public plan = 50*10**18;

  address public tokenPricipal = token;

  uint256 public inversiones = 1;
  uint256[] public primervez = [70, 0, 0, 0, 0];
  uint256[] public porcientos = [0, 0, 0, 0, 0];
  uint256[] public porcientosSalida = [10, 4, 3, 2, 1];

  bool[] public espaciosRango = [false,false,false,false,false,false,false];
  uint256[] public gananciasRango = [20*10**18, 50*10**18, 200*10**18, 500*10**18, 1200*10**18, 6000*10**18, 15000*10**18, 50000*10**18 ];
  uint256[] public puntosRango = [1500*10**18, 5000*10**18, 20000*10**18, 50000*10**18, 120000*10**18, 600000*10**18, 1500000*10**18, 5000000*10**18];

  bool public onOffWitdrawl = true;

  uint256 public dias = 200;
  uint256 public unidades = 86400;

  uint256 public porcent = 200;

  uint256 public porcentPuntosBinario = 5;

  uint256 public descuento = 95;
  uint256 public personas = 2;

  uint256 public totalInvestors = 1;
  uint256 public totalInvested;
  uint256 public totalRefRewards;
  uint256 public totalRefWitdrawl;

  mapping (address => Investor) public investors;
  mapping (address => address) public padre;
  mapping (uint256 => address) public idToAddress;
  mapping (address => uint256) public addressToId;
  mapping (address => bool[]) public rangoReclamado;
  
  uint256 public lastUserId = 1;

  address[] public walletFee = [0x0556a260b9ef10756bc2Df281168697f353d1E8E];
  uint256[] public valorFee = [100];
  uint256 public precioRegistro = 0 * 10**18;
  uint256 public activerFee = 1;
  // 0 desactivada total | 1 activa 5% fee retiro | 2 activa fee retiro y precio de registro

  address[] public wallet = [0x4490566647735e8cBCe0ce96efc8FB91c164859b, 0xe201933cA7B5aF514A1b0119bBC1072a066C06df, 0xe2283cB00B9c32727941728bEDe372005c6ca311, 0x763EB0A2A2925c45927DbF6432f191fc66fbCfa8, 0xDEFf65e4BCF19A52B0DB33E57B7Ce262Fd5dB53F, 0x8A6AC002b64bBba26e746D97d4050e71240B30B0, 0x0bddC342f66F46968A15bD1c16DBEFA5B63a1588];
  uint256[] public valor = [6, 5, 2, 2, 2, 2, 47];

  constructor() {

    Investor storage usuario = investors[owner];

    usuario.registered = true;

    rangoReclamado[_msgSender()] = espaciosRango;

    idToAddress[0] = _msgSender();
    addressToId[_msgSender()] = 0;

  }

  function setInversiones(uint256 _numerodeinverionessinganancia) public onlyOwner returns(uint256){
    inversiones = _numerodeinverionessinganancia;
    return _numerodeinverionessinganancia;
  }

  function setPrecioRegistro(uint256 _precio) public onlyOwner returns(bool){
    precioRegistro = _precio;
    return true;
  }

  function setDescuento(uint256 _descuento) public onlyOwner returns(bool){
    descuento = _descuento;
    return true;
  }

  function setWalletstransfers(address[] memory _wallets, uint256[] memory _valores) public onlyOwner returns(bool){

    wallet = _wallets;
    valor = _valores;

    return true;

  }

  function setWalletFee(address[] memory _wallet, uint256[] memory _fee , uint256 _activerFee ) public onlyOwner returns(bool){
    walletFee = _wallet;
    valorFee = _fee;
    activerFee = _activerFee;
    return true;
  }

  function setPuntosPorcentajeBinario(uint256 _porcentaje) public onlyOwner returns(uint256){

    porcentPuntosBinario = _porcentaje;

    return _porcentaje;
  }

  function setMIN_RETIRO(uint256 _min) public onlyOwner returns(uint256){

    MIN_RETIRO = _min;

    return _min;

  }

  function ChangeTokenPrincipal(address _tokenTRC20) public onlyOwner returns (bool){

    USDT_Contract = TRC20_Interface(_tokenTRC20);

    tokenPricipal = _tokenTRC20;

    return true;

  }

  function setstate() public view  returns(uint256 Investors,uint256 Invested,uint256 RefRewards){
      return (totalInvestors, totalInvested, totalRefRewards);
  }
  
  function tiempo() public view returns (uint256){
     return dias.mul(unidades);
  }

  function setPorcientos(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){

    porcientos[_nivel] = _value;

    return porcientos;

  }

  function setPorcientosSalida(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){

    porcientosSalida[_nivel] = _value;

    return porcientosSalida;

  }

  function setPrimeravezPorcientos(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){

    primervez[_nivel] = _value;

    return primervez;

  }


  function setPlan(uint256 _value) public onlyOwner returns(bool){
    plan = _value;
    return true;
  }

  function setTiempo(uint256 _dias) public onlyAdmin returns(uint256){

    dias = _dias;
    
    return (_dias);

  }

  function setTiempoUnidades(uint256 _unidades) public onlyOwner returns(uint256){

    unidades = _unidades;
    
    return (_unidades);

  }

  function controlWitdrawl(bool _true_false) public onlyOwner returns(bool){

    onOffWitdrawl = _true_false;
    
    return (_true_false);

  }

  function setRetorno(uint256 _porcentaje) public onlyAdmin returns(uint256){

    porcent = _porcentaje;

    return (porcent);

  }

  function column(address yo, uint256 _largo) public view returns(address[] memory) {

    address[] memory res;
    for (uint256 i = 0; i < _largo; i++) {
      res = actualizarNetwork(res);
      res[i] = padre[yo];
      yo = padre[yo];
    }
    
    return res;
  }

  function handLeft(address _user) public view returns(uint256 extra, uint256 reclamados, address referer) {

    Investor storage usuario = investors[_user];
    Hand storage hands = usuario.hands;

    return (hands.lExtra, hands.lReclamados, hands.lReferer);
  }

  function handRigth(address _user) public view returns(uint256 extra, uint256 reclamados, address referer) {

    Investor storage usuario = investors[_user];
    Hand storage hands = usuario.hands;

    return (hands.rExtra, hands.rReclamados, hands.rReferer);
  }

  function depositos(address _user) public view returns(uint256[] memory, uint256[] memory, bool[] memory, bool[] memory, uint256 ){
    Investor storage usuario = investors[_user];

    uint256[] memory amount;
    uint256[] memory time;
    bool[] memory pasive;
    bool[] memory activo;
    uint256 total;
    
     for (uint i = 0; i < usuario.depositos.length; i++) {
       amount = actualizarArrayUint256(amount);
       time = actualizarArrayUint256(time);
       pasive = actualizarArrayBool(pasive);
       activo = actualizarArrayBool(activo);

       Deposito storage dep = usuario.depositos[i];

       time[i] = dep.inicio;
      
      uint finish = dep.inicio + tiempo();
      uint since = usuario.paidAt > dep.inicio ? usuario.paidAt : dep.inicio;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since != 0 && since < till) {
        if (dep.pasivo) {
          total += dep.amount * (till - since) / tiempo() ;
        } 
        activo[i] = true;
      }

      amount[i] = dep.amount;
      pasive[i] = dep.pasivo;      

     }

     return (amount, time, pasive, activo, total);

  }

  function rewardReferers(address yo, uint256 amount, uint256[] memory array, bool _sal) internal {

    address[] memory referi;
    referi = column(yo, array.length);
    uint256 a;
    Investor storage usuario;

    for (uint256 i = 0; i < array.length; i++) {

      if (array[i] != 0) {
        usuario = investors[referi[i]];
        if (usuario.registered && usuario.amount > 0){
          if ( referi[i] != address(0) ) {

            a = amount.mul(array[i]).div(1000);
            if (usuario.amount > a+withdrawable(_msgSender())) {

              usuario.amount -= a;

              discountDeposits(referi[i], a);

              if(_sal){
                usuario.balanceSal += a;
              }else{
                usuario.balanceRef += a;
                usuario.totalRef += a;
              }
              
              totalRefRewards += a;
              
            }else{

              if(_sal){
                usuario.balanceSal += usuario.amount;
              }else{
                usuario.balanceRef += usuario.amount;
                usuario.totalRef += usuario.amount;
              }

              discountDeposits(referi[i], usuario.amount);
              
              totalRefRewards += usuario.amount;
              delete usuario.amount;
              
            }
            

          }else{
            break;
          }
        }
        
      } else {
        break;
      }
      
    }
  }

  function discountDeposits(address _user, uint256 _valor) public { // tiene que se internal

    Investor storage usuario = investors[_user];
    
    for (uint i = 0; i < usuario.depositos.length; i++) {

      Deposito storage dep = usuario.depositos[i];
      if(dep.amount >= _valor){
        dep.amount = dep.amount-_valor;
        delete _valor;
      }else{
        _valor = _valor-dep.amount;
        delete dep.amount;
        
      }
         
    }
  }

  function asignarPuntosBinarios(address _user ,uint256 _puntosLeft, uint256 _puntosRigth) public onlyOwner returns (bool){

    Investor storage usuario = investors[_user];
    require(usuario.registered, "el usuario no esta registrado");

    usuario.hands.lExtra += _puntosLeft;
    usuario.hands.rExtra += _puntosRigth;

    return true;
    

  }

  function asignarPlan(address _user ,uint256 _plan) public onlyAdmin returns (bool){
    if(_plan <= 0 )revert();

    Investor storage usuario = investors[_user];

    if(!usuario.registered)revert();

    uint256 _value = plan * _plan;

    usuario.depositos.push(Deposito(block.timestamp, _value.mul(porcent.div(100)), false));
    usuario.amount += _value.mul(porcent.div(100));


    return true;
  }

  function registro(address _sponsor, uint8 _hand) public{

    if( _hand > 1) revert();
    
    Investor storage usuario = investors[_msgSender()];

    if(usuario.registered)revert();

    if(precioRegistro > 0){

      if( USDT_Contract.allowance(_msgSender(), address(this)) < precioRegistro)revert();
      if( !USDT_Contract.transferFrom(_msgSender(), address(this), precioRegistro))revert();

    }

    if (activerFee >= 2){
       for (uint256 i = 0; i < wallet.length; i++) {
        USDT_Contract.transfer(walletFee[i], precioRegistro.mul(valorFee[i]).div(100));
      }
    }
        usuario.registered = true;
        padre[_msgSender()] = _sponsor;

        if (_sponsor != address(0) ){
          Investor storage sponsor = investors[_sponsor];
          sponsor.directos++;
          if ( _hand == 0 ) {
              
            if (sponsor.hands.lReferer == address(0) ) {

              sponsor.hands.lReferer = _msgSender();
              
            } else {

              address[] memory network;

              network = actualizarNetwork(network);
              network[0] = sponsor.hands.lReferer;
              sponsor = investors[insertionLeft(network)];
              sponsor.hands.lReferer = _msgSender();
              
            }
          }else{

            if ( sponsor.hands.rReferer == address(0) ) {

              sponsor.hands.rReferer = _msgSender();
              
            } else {

              address[] memory network;
              network = actualizarNetwork(network);
              network[0] = sponsor.hands.rReferer;

              sponsor = investors[insertionRigth(network)];
              sponsor.hands.rReferer = _msgSender();
              
            
            }
          }
          
        }
        
        totalInvestors++;

        rangoReclamado[_msgSender()] = espaciosRango;
        idToAddress[lastUserId] = _msgSender();
        addressToId[_msgSender()] = lastUserId;
        
        lastUserId++;


  }

  function buyPlan(uint256 _plan) public {

    if(_plan <= 0 )revert();

    Investor storage usuario = investors[_msgSender()];

    if ( usuario.registered) {

      uint256 _value = plan * _plan;

      if( USDT_Contract.allowance(_msgSender(), address(this)) < _value)revert();
      if( !USDT_Contract.transferFrom(_msgSender(), address(this), _value) )revert();
      
      if (padre[_msgSender()] != address(0) ){
        if (usuario.depositos.length < inversiones ){
          
          rewardReferers(_msgSender(), _value, primervez, false);
          
        }else{
          rewardReferers(_msgSender(), _value, porcientos, false);

        }
      }

      usuario.depositos.push(Deposito(block.timestamp,_value.mul(porcent.div(100)), true));
      usuario.invested += _value;
      usuario.amount += _value.mul(porcent.div(100));

      uint256 left;
      uint256 rigth;
      
      (left, rigth) = corteBinario(_msgSender());
    
      if ( left != 0 && rigth != 0 ) {

        if(left < rigth){
          usuario.hands.lReclamados += left;
          usuario.hands.rReclamados += left;
            
        }else{
          usuario.hands.lReclamados += rigth;
          usuario.hands.rReclamados += rigth;
            
        }
        
      }

      totalInvested += _value;

      for (uint256 i = 0; i < wallet.length; i++) {
        USDT_Contract.transfer(wallet[i], _value.mul(valor[i]).div(100));
      }

      
    } else {
      revert();
    }
    
  }
  
  function withdrawableBinary(address any_user) public view returns (uint256 left, uint256 rigth, uint256 amount) {
    Investor storage user = investors[any_user];
      
    if ( user.hands.lReferer != address(0)) {
        
      address[] memory network;

      network = actualizarNetwork(network);

      network[0] = user.hands.lReferer;

      network = allnetwork(network);
      
      for (uint i = 0; i < network.length; i++) {
      
        user = investors[network[i]];
        left += user.invested;
      }
        
    }
    user = investors[any_user];

    left += user.hands.lExtra;
    left -= user.hands.lReclamados;
      
    if ( user.hands.rReferer != address(0)) {
        
        address[] memory network;

        network = actualizarNetwork(network);

        network[0] = user.hands.rReferer;

        network = allnetwork(network);
        
        for (uint i = 0; i < network.length; i++) {
        
          user = investors[network[i]];
          rigth += user.invested;
        }
        
    }

    user = investors[any_user];

    rigth += user.hands.rExtra;
    rigth -= user.hands.rReclamados;

    if (left < rigth) {
      if (left.mul(porcentPuntosBinario).div(100) <= user.amount ) {
        amount = left.mul(porcentPuntosBinario).div(100) ;
          
      }else{
        amount = user.amount;
          
      }
      
    }else{
      if (rigth.mul(porcentPuntosBinario).div(100) <= user.amount ) {
        amount = rigth.mul(porcentPuntosBinario).div(100) ;
          
      }else{
        amount = user.amount;
          
      }
    }
  
  }

   function withdrawableRange(address any_user) public view returns (uint256 amount) {
    Investor memory user = investors[any_user];

    uint256 left = user.hands.lReclamados;
    left += user.hands.lExtra;

    uint256 rigth = user.hands.rReclamados;
    rigth += user.hands.rExtra;

    if (left < rigth) {

      amount = left ;
      
    }else{

      amount = rigth;

    }
  
  }

  function newRecompensa() public {

    if (!onOffWitdrawl)revert();

    uint256 amount = withdrawableRange(_msgSender());

    for (uint256 index = 0; index < gananciasRango.length; index++) {

      if(amount >= puntosRango[index] && !rangoReclamado[_msgSender()][index]){

        USDT_Contract.transfer(_msgSender(), gananciasRango[index]);
        rangoReclamado[_msgSender()][index] = true;
      }
      
    }

  }

  function personasBinary(address any_user) public view returns (uint256 left, uint256 pLeft, uint256 rigth, uint256 pRigth) {
    Investor memory referer = investors[any_user];

    if ( referer.hands.lReferer != address(0)) {

      address[] memory network;

      network = actualizarNetwork(network);

      network[0] = referer.hands.lReferer;

      network = allnetwork(network);

      for (uint i = 0; i < network.length; i++) {
        
        referer = investors[network[i]];
        left += referer.invested;
        pLeft++;
      }
        
    }

    referer = investors[any_user];
    
    if ( referer.hands.rReferer != address(0)) {
        
      address[] memory network;

      network = actualizarNetwork(network);

      network[0] = referer.hands.rReferer;

      network = allnetwork(network);
      
      for (uint b = 0; b < network.length; b++) {
        
        referer = investors[network[b]];
        rigth += referer.invested;
        pRigth++;
      }
    }

  }

  function actualizarNetwork(address[] memory oldNetwork)public pure returns ( address[] memory) {
    address[] memory newNetwork =   new address[](oldNetwork.length+1);

    for(uint i = 0; i < oldNetwork.length; i++){
        newNetwork[i] = oldNetwork[i];
    }
    
    return newNetwork;
  }

  function actualizarArrayBool(bool[] memory old)public pure returns ( bool[] memory) {
    bool[] memory newA =   new bool[](old.length+1);

    for(uint i = 0; i < old.length; i++){
        newA[i] = old[i];
    }
    
    return newA;
  }

  function actualizarArrayUint256(uint256[] memory old)public pure returns ( uint256[] memory) {
    uint256[] memory newA =   new uint256[](old.length+1);

    for(uint i = 0; i < old.length; i++){
        newA[i] = old[i];
    }
    
    return newA;
  }

  function allnetwork( address[] memory network ) public view returns ( address[] memory) {

    Investor storage user;

    for (uint i = 0; i < network.length; i++) {

      user = investors[network[i]];
      
      address userLeft = user.hands.lReferer;
      address userRigth = user.hands.rReferer;

      for (uint u = 0; u < network.length; u++) {
        if (userLeft == network[u]){
          userLeft = address(0);
        }
        if (userRigth == network[u]){
          userRigth = address(0);
        }
      }

      if( userLeft != address(0) ){
        network = actualizarNetwork(network);
        network[network.length-1] = userLeft;
      }

      if( userRigth != address(0) ){
        network = actualizarNetwork(network);
        network[network.length-1] = userRigth;
      }

    }

    return network;
  }

  function insertionLeft(address[] memory network) public view returns ( address wallett) {

    Investor memory user;

    for (uint i = 0; i < network.length; i++) {

      user = investors[network[i]];
      
      address userLeft = user.hands.lReferer;

      if( userLeft == address(0) ){
        return  network[i];
      }

      network = actualizarNetwork(network);
      network[network.length-1] = userLeft;

    }
    insertionLeft(network);
  }

  function insertionRigth(address[] memory network) public view returns (address wallett) {
    Investor memory user;

    for (uint i = 0; i < network.length; i++) {
      user = investors[network[i]];

      address userRigth = user.hands.rReferer;

      if( userRigth == address(0) ){
        return network[i];
      }

      network = actualizarNetwork(network);
      network[network.length-1] = userRigth;

    }
    insertionRigth(network);
  }

  function withdrawable(address any_user) public view returns (uint256) {

    Investor memory investor2 = investors[any_user];

    uint256 binary;
    uint256 saldo = investor2.amount+investor2.balanceRef+investor2.balanceSal;
    
    uint256 left;
    uint256 rigth;

    uint256[] memory amount;
    uint256[] memory time;
    bool[] memory pasive;
    bool[] memory activo;
    uint256 total;

    (left, rigth, binary) = withdrawableBinary(any_user);

    (amount, time, pasive, activo, total) = depositos(any_user);

    total += binary;
    total += investor2.balanceRef;

    if (saldo >= total) {
      return total;
    }else{
      return saldo;
    }

  }

  function corteBinario(address any_user) public view returns (uint256, uint256) {

    uint256 binary;
    uint256 left;
    uint256 rigth;

    (left, rigth, binary) = withdrawableBinary(any_user);

    return (left, rigth);

  }

  function withdraw() public {

    if (!onOffWitdrawl)revert();

    uint256 _value = withdrawable(_msgSender());
    

    if( USDT_Contract.balanceOf(address(this)) < _value )revert();
    if( _value < MIN_RETIRO )revert();

    if ( activerFee >= 1 ) {
      for (uint256 i = 0; i < walletFee.length; i++) {
        USDT_Contract.transfer(walletFee[i], _value.mul(valorFee[i]).div(100));
      }
    
      USDT_Contract.transfer(_msgSender(), _value.mul(descuento).div(100));
      
    }else{
      USDT_Contract.transfer(_msgSender(), _value.mul(descuento).div(100));
      
    }

    rewardReferers(_msgSender(), _value, porcientosSalida, true);

    Investor storage usuario = investors[_msgSender()];

    uint256 binary;
    uint256 left;
    uint256 rigth;

    (left, rigth, binary) = withdrawableBinary(_msgSender());

    discountDeposits(_msgSender(), binary);

    (left, rigth) = corteBinario(_msgSender());
    
    if ( left != 0 && rigth != 0 ) {

      if(left < rigth){
        usuario.hands.lReclamados += left;
        usuario.hands.rReclamados += left;
          
      }else{
        usuario.hands.lReclamados += rigth;
        usuario.hands.rReclamados += rigth;
          
      }
      
    }

    usuario.amount -= _value.sub(usuario.balanceRef+usuario.balanceSal);
    usuario.withdrawn += _value;
    usuario.paidAt = block.timestamp;
    delete usuario.balanceRef;
    delete usuario.balanceSal;

    totalRefWitdrawl += _value;

  }

  function redimTokenPrincipal02(uint256 _value) public onlyOwner returns (uint256) {

    if ( USDT_Contract.balanceOf(address(this)) < _value)revert();

    USDT_Contract.transfer(owner, _value);

    return _value;

  }

  function redimTRX() public onlyOwner returns (uint256){

    owner.transfer(address(this).balance);

    return address(this).balance;

  }

  fallback() external payable {}

  receive() external payable {}

}