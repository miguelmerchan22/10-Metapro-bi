import React, { Component } from "react";

export default class Datos extends Component {
  constructor(props) {
    super(props);

    this.state = {
      totalInvestors: 0,
      totalInvested: 0,
      totalRefRewards: 0,
      precioSITE: 1,
      wallet: "",
      plan: 0,
      cantidad: 0,
      hand: 0,
    };

    this.totalInvestors = this.totalInvestors.bind(this);
    this.rateSITE = this.rateSITE.bind(this);

    this.handleChangeWALLET = this.handleChangeWALLET.bind(this);
    this.handleChangePLAN = this.handleChangePLAN.bind(this);
    this.handleChangeHAND = this.handleChangeHAND.bind(this);
    this.handleChangeCANTIDAD = this.handleChangeCANTIDAD.bind(this);

    this.asignarPlan = this.asignarPlan.bind(this);
  }

  async componentDidMount() {
    if (typeof window.ethereum !== "undefined") {
      var resultado = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      console.log(resultado[0]);
      this.setState({
        currentAccount: resultado[0],
      });
    }
    setInterval(async () => {
      if (typeof window.ethereum !== "undefined") {
        var resultado = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        console.log(resultado[0]);
        this.setState({
          currentAccount: resultado[0],
        });
      }
    }, 7 * 1000);
    setInterval(() => this.totalInvestors(), 3 * 1000);
  }

  handleChangeWALLET(event) {
    console.log(event);
    this.setState({ wallet: event.target.value });
  }

  handleChangePLAN(event) {
    this.setState({ plan: event.target.value });
  }

  handleChangeHAND(event) {
    this.setState({ plan: event.target.value });
  }

  handleChangeCANTIDAD(event) {
    this.setState({ cantidad: event.target.value });
  }

  async rateSITE() {
    /*
    var proxyUrl = cons.proxy;
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
  }

  async totalInvestors() {
    //await this.rateSITE();

    let esto = await this.props.wallet.contractBinary.methods
      .setstate()
      .call({ from: this.state.currentAccount });

    var retirado = await this.props.wallet.contractBinary.methods
      .totalRefWitdrawl()
      .call({ from: this.state.currentAccount });

    var decimales = await this.props.wallet.contractToken.methods
      .decimals()
      .call({ from: this.state.currentAccount });

    //console.log(esto);
    this.setState({
      totalInvestors: esto.Investors,
      totalInvested: esto.Invested / 10 ** decimales,
      totalRefRewards: esto.RefRewards / 10 ** decimales,
      retirado: retirado / 10 ** decimales,
    });
  }

  async asignarPlan() {
    if (this.props.version <= 1) {
      var transaccion = await this.props.wallet.contractBinary.methods
        .asignarPlan(this.state.wallet, this.state.plan)
        .send({ from: this.state.currentAccount });
    } else {
      transaccion = await this.props.wallet.contractBinary.methods
        .asignarPlan(this.state.wallet, this.state.plan)
        .send({ from: this.state.currentAccount });
    }
    alert("verifica la transaccion " + transaccion);
    setTimeout(
      window.open(`https://bscscan.com/tx/${transaccion}`, "_blank"),
      3000
    );
    this.setState({ plan: 0 });
  }

  render() {
    if (this.props.admin === true) {
      return (
        <div className="row counters">
          <div className="col-lg-3 col-12 text-center text-white">
            <h3>{this.state.totalInvestors}</h3>
            <p>Inversores Globales</p>
          </div>

          <div className="col-lg-3 col-12 text-center text-white">
            <h3>
              {(this.state.totalInvested / this.state.precioSITE).toFixed(2)}{" "}
              USDT
            </h3>
            <p>Invertido en Plataforma</p>
          </div>

          <div className="col-lg-3 col-12 text-center text-white">
            <h3>
              {(this.state.totalRefRewards / this.state.precioSITE).toFixed(2)}{" "}
              USDT{" "}
            </h3>
            <p>Total Recompensas por Referidos</p>
          </div>

          <div className="col-lg-3 col-12 text-center text-white">
            <h3>{this.state.retirado} USDT</h3>
            <p>retirado Global</p>
          </div>

          <div className="col-lg-3 col-12 text-center">
            <input type="text" onChange={this.handleChangeWALLET} />
            <p>Wallet</p>
          </div>

          <div className="col-lg-3 col-12 text-center">
            <input type="number" onChange={this.handleChangeCANTIDAD} />

            <p>
              <button
                type="button"
                className="btn btn-info d-block text-center mx-auto mt-1"
                onClick={async () => {
                  var transaccion =
                    await this.props.wallet.contractToken.methods
                      .transfer(
                        this.state.wallet,
                        parseInt(this.state.cantidad * 10 ** 6)
                      )
                      .send({ from: this.props.wallet.currentAccount });

                  alert("verifica la transaccion " + transaccion);
                  setTimeout(
                    window.open(
                      `https://bscscan.com/tx/${transaccion}`,
                      "_blank"
                    ),
                    3000
                  );
                  this.setState({ cantidad: 0 });
                }}
              >
                Send Token
              </button>
            </p>
          </div>

          <div className="col-lg-3 col-12 text-center">
            <input type="number" onChange={this.handleChangePLAN} />
            <p>
              <button
                type="button"
                className="btn btn-info d-block text-center mx-auto mt-1"
                onClick={() => this.asignarPlan()}
              >
                Asignar plan
              </button>
            </p>
          </div>
        </div>
      );
    } else {
      return <></>;
    }
  }
}
