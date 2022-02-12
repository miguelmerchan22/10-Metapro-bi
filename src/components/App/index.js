import React, { Component } from "react";

import Web3 from "web3";

import Home from "../V1Home";
import TronLinkGuide from "../TronLinkGuide";
import cons from "../../cons"

import abiToken from "../../token";
import abiBinario from "../../binary";

var addressToken = cons.TOKEN;
var addressBinary = cons.SC;
var chainId = '0xC7';

if(cons.testnet){
  addressToken = cons.TOKENtest;
  addressBinary = cons.SCtest;
  chainId = '0x61';
}


class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      admin: false,
      metamask: false,
      conectado: false,
      currentAccount: "0x0000000000000000000000000000000000000000",
      binanceM:{
        web3: null,
        contractToken: null,
        contractBinary: null
      }
      
    };
  }

  async componentDidMount() {

    this.conectar();

    setInterval(() => {
      this.conectar();
    }, 3*1000);

  }

  async conectar(){


        if (typeof window.ethereum !== 'undefined') {  
          
          this.setState({
            metamask: true
          })

          await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: chainId}],
          });


          window.ethereum.request({ method: 'eth_requestAccounts' })
          .then(async(accounts) => {
            
            var web3 = new Web3(window.web3.currentProvider);
            var contractToken = new web3.eth.Contract(
              abiToken,
              addressToken
            );
            var contractBinary = new web3.eth.Contract(
              abiBinario,
              addressBinary
            );

            var contractTokenPRUEBA1 = new web3.eth.Contract(
              abiToken,
              cons.PRUEBA1
            );

            var isAdmin = await contractBinary.methods.admin(accounts[0]).call({from:accounts[0]});

            console.log( contractTokenPRUEBA1.methods.decimals().call({from:accounts[0]}));

            this.setState({
              conectado: true,
              currentAccount: accounts[0],
              admin: isAdmin,
              binanceM:{
                web3: web3,
                contractToken: contractToken,
                contractBinary: contractBinary,
                contractTokenPRUEBA1: contractTokenPRUEBA1
              }
            })
            
          })
          .catch((error) => {
            console.error(error)
            this.setState({
              conectado: false,
              admin: false,
              binanceM:{
                web3: null,
                contractToken: null,
                contractBinary: null
              }
            })   
          });
  
        } else {    
          this.setState({

            metamask: false,
            conectado: false,
            admin: false,
            binanceM:{
              web3: null,
              contractToken: null,
              contractBinary: null
            }
          })        
             
        }

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
        return(<Home admin={this.state.admin} contractAddress={this.state.binanceM.contractBinary._address} version="5" wallet={this.state.binanceM} currentAccount={this.state.currentAccount}/>);
    }


  }
}
export default App;

// {tWeb()}
