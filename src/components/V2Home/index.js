import React, { Component } from "react";

import CrowdFunding from "../CrowdFunding";
import Oficina from "../Oficina";
import Datos from "../Datos";
import Depositos from "../Depositos";

export default class Home extends Component {
  
  render() {

      return (
        <>
          
          <div>
            <div>
              <section id="why-us" className="wow fadeIn mt-5">
                <div className="container">
                  <header className="section-header">
                      <h3>Make your investment</h3>
                  </header>
                  <div  className="row row-eq-height justify-content-center">
                    <CrowdFunding wallet={this.props.wallet} currentAccount={this.state.currentAccount}/>
                  </div>
                  <div >
                  <Datos admin={this.props.admin} wallet={this.props.wallet} currentAccount={this.state.currentAccount}/>
                  </div>
                </div>
              </section>

              <section id="services" className="section-bg">
                <Oficina  wallet={this.props.wallet} currentAccount={this.state.currentAccount}/>
                <hr></hr>
                <Depositos  wallet={this.props.wallet} currentAccount={this.state.currentAccount}/>
              </section>
            </div>
          </div>
        </>
      );
  }
}
