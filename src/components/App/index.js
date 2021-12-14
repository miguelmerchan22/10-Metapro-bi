import React, { Component } from "react";

import Web3 from "web3";

import Home from "../V1Home";
import TronLinkGuide from "../TronLinkGuide";
import cons from "../../cons"

import abiToken from "../../token";
import abiBinario from "../../binary";

const addressToken = cons.TOKEN;
const addressBinary = cons.SC2;

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      admin: false,
      metamask: false,
      conectado: false,
      currentAccount: null,
      binanceM:{
        web3: null,
        contractToken: null,
        contractBinary: null
      }
      
    };
  }

  async componentDidMount() {

      if (typeof window.ethereum !== 'undefined') {           
        var resultado = await window.ethereum.request({ method: 'eth_requestAccounts' });
          //console.log(resultado[0]);
          this.setState({
            currentAccount: resultado[0],
            metamask: true,
            conectado: true
          })

      } else {          
        this.setState({
          metamask: false,
          conectado: false
        })      
      }

      setInterval(async() => {
        if (typeof window.ethereum !== 'undefined') {           
          var resultado = await window.ethereum.request({ method: 'eth_requestAccounts' });
            //console.log(resultado[0]);
            this.setState({
              currentAccount: resultado[0],
              metamask: true,
              conectado: true
            })
  
        } else {          
          this.setState({
            metamask: false,
            conectado: false
          })      
        }

      },7*1000);


    try {         
      var web3 = new Web3(window.web3.currentProvider);// mainet... metamask
      var contractToken = new web3.eth.Contract(
        abiToken,
        addressToken
      );
      var contractBinary = new web3.eth.Contract(
        abiBinario,
        addressBinary
      );

      this.setState({
        binanceM:{
          web3: web3,
          contractToken: contractToken,
          contractBinary: contractBinary
        }
      })
      //web3 = new Web3(new Web3.providers.HttpProvider("https://data-seed-prebsc-1-s1.binance.org:8545/"));
    } catch (error) {
        alert(error);
    }  

    var isAdmin = await contractBinary.methods.admin(this.state.currentAccount).call({from:this.state.currentAccount});
    
    this.setState({
      admin: isAdmin,

    })

  }


  render() {

    var getString = "";
    var loc = document.location.href;
    //console.log(loc);
    if(loc.indexOf('?')>0){
              
      getString = loc.split('?')[1];
      getString = getString.split('#')[0];

    }

    if (!this.state.metamask) return (
      <>
        <div className="container">
          <TronLinkGuide />
        </div>
      </>
      );

    if (!this.state.conectado) return (
      <>
        <div className="container">
          <TronLinkGuide installed />
        </div>
      </>
      );

    switch (getString) {
      case "shasta":
      case "test":
      case "v0":
      case "V0": 
        return(<Home admin={this.state.admin} contractAddress={cons.SCtest} version="999" wallet={this.state.binanceM} currentAccount={this.state.currentAccount}/>);
      default:
        return(<Home admin={this.state.admin} contractAddress={cons.SC2} version="5" wallet={this.state.binanceM} currentAccount={this.state.currentAccount}/>);
    }


  }
}
export default App;

// {tWeb()}
