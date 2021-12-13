import React, { Component } from "react";

export default class Depositos extends Component {
  constructor(props) {
    super(props);

    this.state = {
      direccion: "",
      link: "Make an investment to get the referral LINK",
      registered: false,
      balanceRef: 0,
      totalRef: 0,
      invested: 0,
      paidAt: 0,
      my: 0,
      almacen: 0,
      withdrawn: 0,
      precioSITE: 1,
      valueSITE: 0,
      valueUSDT: 0,
      personasIzquierda: 0,
      puntosIzquierda: 0,
      personasDerecha: 0,
      puntosDerecha: 0,
      bonusBinario: 0,
      puntosEfectivosIzquierda: 0,
      puntosEfectivosDerecha: 0,
      puntosReclamadosIzquierda: 0,
      puntosReclamadosDerecha: 0,
      puntosLostIzquierda: 0,
      puntosLostDerecha: 0,
      directos: 0,

    };

    this.Investors = this.Investors.bind(this);
    this.Investors2 = this.Investors2.bind(this);
    this.Investors3 = this.Investors3.bind(this);
    this.Link = this.Link.bind(this);
    this.withdraw = this.withdraw.bind(this);

    this.rateSITE = this.rateSITE.bind(this);
    this.handleChangeSITE = this.handleChangeSITE.bind(this);
    this.handleChangeUSDT = this.handleChangeUSDT.bind(this);
  }

  handleChangeSITE(event) {
    this.setState({valueSITE: event.target.value});
  }

  handleChangeUSDT(event) {
    this.setState({valueUSDT: event.target.value});
  }

  async componentDidMount() {
    if (typeof window.ethereum !== 'undefined') {           
      var resultado = await window.ethereum.request({ method: 'eth_requestAccounts' });
        console.log(resultado[0]);
        this.setState({
          currentAccount: resultado[0]
        })

    }
    setInterval(async() => {
      if (typeof window.ethereum !== 'undefined') {           
        var resultado = await window.ethereum.request({ method: 'eth_requestAccounts' });
          console.log(resultado[0]);
          this.setState({
            currentAccount: resultado[0]
          })
  
      }

    },7*1000);
    setInterval(() => this.Investors2(),3*1000);
    setInterval(() => this.Investors3(),3*1000);
    setInterval(() => this.Investors(),3*1000);
    setInterval(() => this.Link(),3*1000);
    
  };

  async rateSITE(){
    /*var proxyUrl = cons.proxy;
    var apiUrl = cons.PRE;
    var response;

    try {
      response = await fetch(proxyUrl+apiUrl);
    } catch (err) {
      console.log(err);
      return this.state.precioSITE;
    }

    var json = await response.json();

    this.setState({
      precioSITE: json.Data.precio
    });

    return json.Data.precio;*/

    return 1;

  };

  async Link() {
    const {registered} = this.state;
    if(registered){

      let loc = document.location.href;
      if(loc.indexOf('?')>0){
        loc = loc.split('?')[0];
      }

      if(loc.indexOf('#')>0){
        loc = loc.split('#')[0];
      }
      let mydireccion = this.state.currentAccount;
      mydireccion = await this.props.wallet.contractBinary.methods.addressToId(this.state.currentAccount).call({from:this.state.currentAccount});

      mydireccion = loc+'?ref='+mydireccion;
      var link = mydireccion+"&hand=izq";
      var link2 = mydireccion+"&hand=der";
      this.setState({
        link: link,
        link2: link2,
      });
    }else{
      this.setState({
        link: "Make an investment to get the referral LINK",
        link2: "Make an investmentnto get the referral LINK",
      });
    }
  }


  async Investors() {

    let usuario = await this.props.wallet.contractBinary.methods.investors(this.state.currentAccount).call({from:this.state.currentAccount});

    usuario.withdrawable = await this.props.wallet.contractBinary.methods.withdrawable(this.state.currentAccount).call({from:this.state.currentAccount});
    
    var decimales = await this.props.wallet.contractToken.methods.decimals().call({from:this.state.currentAccount});

    var verdepositos = await this.props.wallet.contractBinary.methods.depositos(this.state.currentAccount).call({from:this.state.currentAccount});

    usuario.inicio = 1000;

    var listaDepositos = (
      <div className="box">
        <h3 className="title">There is not yet deposits.</h3>

      </div>
    );

    if (verdepositos[0].length > 0) {
      var depositos = await this.props.wallet.contractBinary.methods.depositos(this.state.currentAccount).call({from:this.state.currentAccount});
      depositos.amount =  depositos[0];
      delete depositos[0];
      depositos.tiempo =  depositos[1];
      delete depositos[1];
      depositos.pasivo =  depositos[2];
      delete depositos[2];
      depositos.activo =  depositos[3];
      delete depositos[3];

      //console.log(depositos);

      listaDepositos = [];

      var tiempo = await this.props.wallet.contractBinary.methods.tiempo().call({from:this.state.currentAccount});

      tiempo = tiempo*1000;

      let porcent = await this.props.wallet.contractBinary.methods.porcent().call({from:this.state.currentAccount});

        porcent = porcent/100;

      for (let i = 0; i < depositos.amount.length; i++) {

      

        var porcentiempo = (((Date.now()-(depositos.tiempo[i]*1000)))*100)/tiempo;


        var fecha = new Date((depositos.tiempo[i]*1000)+tiempo);
        fecha = ""+fecha;

        var proceso;
        if (depositos.activo[i]  && ((depositos.amount[i]/10**18)*(porcentiempo/100)) < (depositos.amount[i]/10**18)) {
          if (depositos.pasivo[i]  ) {
            proceso = <b>Plan Binary (ACTIVE)</b> 
          } else {
            proceso = <b>Plan FREE Binary (ACTIVE)</b> 
          }
        }else{
          if (depositos.pasivo[i]  ) {
            proceso = <b>Plan Binario (FINALIZED)</b> 
          }else{
            proceso = <b>Plan FREE Binario (FINALIZED)</b> 
          }
        }
        

        listaDepositos[i] = (
          <div className="box" key={"depsits-"+i}>
          <h3 className="title">{(depositos.amount[i]/10**18)/porcent} USDT</h3>
            Estimate time <b>{fecha}</b>
          <div className="progress" style={{"height": "20px"}}>
            <div className="progress-bar-striped progress-bar-animated bg-success" role="progressbar" style={{"width": porcentiempo+"%"}} aria-valuenow={this.state.porcentiempo} aria-valuemin="0" aria-valuemax="100"></div>
          </div>
          <br></br>
          {proceso}
    
    
        </div>
        );
        
      }
    }

    //console.log(usuario);

    

    this.setState({
      registered: usuario.registered,
      balanceRef: usuario.balanceRef/10**decimales,
      totalRef: usuario.totalRef/10**decimales,
      invested: usuario.invested/10**decimales,
      paidAt: usuario.paidAt/10**decimales,
      my: usuario.withdrawable/10**decimales,
      withdrawn: usuario.withdrawn/10**decimales,
      almacen: usuario.almacen/10**decimales,
      porcentiempo: porcentiempo,
      directos: usuario.directos,
      depositos: listaDepositos
    });

  };

  async Investors2() {

    //var precioSITE = await this.rateSITE();

    /*this.setState({
      precioSITE: precioSITE
    });*/

  };

  async Investors3() {

    var {balanceRef, my, almacen, directos, valorPlan } = this.state;

    //Personas y puntos totales
    let puntos = await this.props.wallet.contractBinary.methods.personasBinary(this.state.currentAccount).call({from:this.state.currentAccount});

    // monto de bonus y puntos efectivos
    let bonusBinario = await this.props.wallet.contractBinary.methods.withdrawableBinary(this.state.currentAccount).call({from:this.state.currentAccount});
  
    var available = (balanceRef+my+almacen);

    if(directos >= 2 && available < valorPlan ){
      bonusBinario.amount = bonusBinario.amount/10**18;
    }else{
      bonusBinario.amount = 0;
    }

    let brazoIzquierdo = await this.props.wallet.contractBinary.methods.handLeft(this.state.currentAccount).call({from:this.state.currentAccount});

    let brazoDerecho = await this.props.wallet.contractBinary.methods.handRigth(this.state.currentAccount).call({from:this.state.currentAccount});

    //console.log(brazoDerecho);

    this.setState({
      personasIzquierda: puntos.pLeft,
      personasDerecha: puntos.pRigth,

      puntosIzquierda: puntos.left/10**18,
      puntosDerecha: puntos.rigth/10**18,

      bonusBinario: bonusBinario.amount,

      puntosEfectivosIzquierda: bonusBinario.left/10**18,
      puntosEfectivosDerecha: bonusBinario.rigth/10**18,

      puntosReclamadosIzquierda: brazoIzquierdo.reclamados/10**18,
      puntosReclamadosDerecha: brazoDerecho.reclamados/10**18

    });

  };

  async withdraw(){
    const { balanceRef, my, almacen, directos, valorPlan, bonusBinario } = this.state;

    var available = (balanceRef+my+almacen);
    if(directos >= 2 && available < valorPlan){
      available += bonusBinario;
    }
    available = available.toFixed(8);
    available = parseFloat(available);

    var decimales = await this.props.wallet.contractToken.methods.decimals().call({from:this.state.currentAccount});

    var MIN_RETIRO = await this.props.wallet.contractBinary.methods.MIN_RETIRO().call({from:this.state.currentAccount});

    MIN_RETIRO = MIN_RETIRO/10**decimales;

    if ( available > MIN_RETIRO ){
      await this.props.wallet.contractBinary.methods.withdrawToDeposit().send({from:this.state.currentAccount});
      await this.props.wallet.contractBinary.methods.withdraw().send({from:this.state.currentAccount});
    }else{
      if (available < MIN_RETIRO) {
        window.alert("The minimum to withdraw are: "+(MIN_RETIRO)+" USDT");
      }
    }
  };


  render() {   

    return (

      <div className="container">

        <header style={{'textAlign': 'center'}} className="section-header">
          <h3 className="white">
            <i className="fa fa-university mr-2" aria-hidden="true"></i>
            <span style={{'fontWeight': 'bold'}}>
              Deposits:
            </span>
          </h3>
          <div className="row text-center">
            <div className="col-md-12 col-lg-10 offset-lg-1 wow bounceInUp" data-wow-duration="1s">
              {this.state.depositos}
              
            </div>
          </div>


        </header>


      </div>

    );
  }
}
