
function signInOption() {
  signup = document.getElementsByClassName('signUp')[0]
  logIn = document.getElementsByClassName('login')[0]

  if (signup.style.display == "none") {
    signup.style.display = "block";
    logIn.style.display = "none";
  }
  else {
    signup.style.display = "none";
    logIn.style.display = "block";
  }
}

function myFunction() {
    document.getElementById("myDropdown").classList.toggle("show");
}
  
function filterFunction() {
  var input, filter, ul, li, a, i;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();
  div = document.getElementById("myDropdown");
  a = div.getElementsByTagName("a");
  for (i = 0; i < a.length; i++) {
    txtValue = a[i].textContent || a[i].innerText;
    if (txtValue.toUpperCase().indexOf(filter) > -1) {
      a[i].style.display = "";
    } else {
      a[i].style.display = "none";
    }
  }
}


