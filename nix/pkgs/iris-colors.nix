{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "iris-colors";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Harman1307";
    repo = "iris";
    rev = "v${version}";
    hash = "sha256-l2X1TVTHfYCqDZJcvvgVLXU/9NXcNb2rGHiN3PgfswE=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    numpy
    pillow
  ];

  # Não há suíte de testes unitários empacotada no upstream
  doCheck = false;

  meta = {
    description = "Gerador semântico de paleta de cores a partir do wallpaper";
    homepage = "https://github.com/Harman1307/iris";
    license = lib.licenses.mit;
    mainProgram = "iris";
    platforms = lib.platforms.all;
  };
}
