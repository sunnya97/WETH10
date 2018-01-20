const WETH10 = artifacts.require('WETH10');

contract('WETH10', function (accounts) {
  it('WETH10', async function () {
    let temp = await WETH10.new()
    console.log(temp)
  });
});
